#pragma once

#include <QMainWindow>

QT_BEGIN_NAMESPACE
namespace Ui {
class GLWindow;
}
QT_END_NAMESPACE

class GLWindow : public QMainWindow
{
    Q_OBJECT

public:
    explicit GLWindow(QWidget* parent = nullptr);
    ~GLWindow();

private:
    Ui::GLWindow* ui;
};
