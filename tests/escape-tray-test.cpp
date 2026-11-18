#include "mainwindow.h"
#include "src/core/BatteryManager.h"
#include "src/history/BatteryHistoryStore.h"
#include "util/AppSettings.h"

#include <QAbstractItemView>
#include <QApplication>
#include <QComboBox>
#include <QDialog>
#include <QLineEdit>
#include <QPushButton>
#include <QSettings>
#include <QSpinBox>
#include <QSystemTrayIcon>
#include <QTableWidget>
#include <QTemporaryDir>
#include <QTimer>
#include <QtTest/QTest>

#include <cstdlib>
#include <iostream>

void check(bool condition, const char *name)
{
    if (!condition) {
        std::cerr << "FAIL: " << name << '\n';
        std::exit(1);
    }
}

int main(int argc, char **argv)
{
    QApplication app(argc, argv);
    app.setQuitOnLastWindowClosed(false);
    app.setOrganizationName("EscapeTrayTests");
    app.setApplicationName("Isolated");
    QTemporaryDir dir;
    check(dir.isValid(), "temporary settings directory");
    QSettings::setDefaultFormat(QSettings::IniFormat);
    QSettings::setPath(QSettings::IniFormat, QSettings::UserScope, dir.path());
    QSettings::setPath(QSettings::IniFormat, QSettings::SystemScope, dir.path());

    bool completed = false;
    QTimer::singleShot(0, &app, [&] {
        BatteryManager manager; // No providers or polling: no hardware access.
        BatteryHistoryStore history(nullptr, dir.filePath("history.sqlite"));
        MainWindow window(&manager, &history);
        auto *tray = window.findChild<QSystemTrayIcon *>();
        check(tray && tray->isVisible(), "tray initialized");
        window.show();
        window.resize(1000, 600);
        QTest::keyClick(&window, Qt::Key_Escape);
        check(window.isHidden() && tray->isVisible(), "Esc hides to tray without quitting");
        check(AppSettings::windowSize() == QSize(1000, 600), "Esc saves size through closeEvent");
        check(QMetaObject::invokeMethod(&window, "onTrayActivated", Qt::DirectConnection), "restore slot");
        check(window.isVisible() && !window.isMinimized(), "tray restores hidden window");

        // Use real Qt child controls to exercise key-event propagation.
        QLineEdit edit(&window);
        QSpinBox spin(&window);
        QPushButton button(&window);
        QTableWidget table(1, 1, &window);
        QComboBox combo(&window);
        combo.addItems({"one", "two"});
        edit.setText("unchanged");
        QWidget *controls[] = {&edit, &spin, &button, &table, &combo};
        for (QWidget *control : controls) {
            window.show();
            control->show();
            control->setFocus();
            QTest::keyClick(control, Qt::Key_Escape);
            check(window.isHidden() && tray->isVisible(), "focused child Esc hides to tray");
            check(QMetaObject::invokeMethod(&window, "onTrayActivated", Qt::DirectConnection), "repeat restore");
        }
        check(edit.text() == "unchanged", "Esc does not change input text");

        window.raise();
        window.activateWindow();
        combo.setFocus();
        // Windows focus/activation is asynchronous; settle it before opening the popup.
        QTest::qWait(100);
        combo.showPopup();
        check(QTest::qWaitFor([&combo] { return combo.view()->isVisible(); }), "dropdown opened");
        QTest::keyClick(combo.view(), Qt::Key_Escape);
        check(!combo.view()->isVisible() && window.isVisible(), "Esc closes dropdown only");
        QDialog dialog(&window);
        dialog.show();
        QTest::keyClick(&dialog, Qt::Key_Escape);
        check(dialog.isHidden() && dialog.result() == QDialog::Rejected && window.isVisible(),
              "Esc cancels dialog only");

        QTest::keyClick(&window, Qt::Key_A);
        QTest::keyClick(&window, Qt::Key_Escape, Qt::ControlModifier);
        check(window.isVisible(), "other keys and modified Esc do not hide");
        tray->hide();
        QTest::keyClick(&window, Qt::Key_Escape);
        check(window.isVisible(), "no tray: Esc must not close window");
        tray->show();
        window.close();
        check(window.isHidden() && tray->isVisible(), "close button still hides to tray");
        // Complete on the next main-loop turn. An unexpected quit during Esc must
        // exit before this timer runs, rather than being ignored outside app.exec().
        QTimer::singleShot(0, &app, [&] { completed = true; app.quit(); });
    });
    const int result = app.exec();
    check(completed && result == 0, "Esc/close must not quit the running application");
    std::cout << "Esc-to-tray regression tests passed\n";
    return 0;
}
