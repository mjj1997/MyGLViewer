#pragma once

#include "model.h"

#include <QOpenGLFunctions_4_5_Core>
#include <QOpenGLWidget>

class GLView : public QOpenGLWidget, QOpenGLFunctions_4_5_Core
{
    Q_OBJECT
public:
    explicit GLView(QWidget* parent = nullptr);
    ~GLView();

protected:
    virtual void initializeGL();
    virtual void resizeGL(int w, int h);
    virtual void paintGL();
private:
    Model* m_model{ nullptr };

signals:
};
