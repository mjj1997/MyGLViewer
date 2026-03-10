#pragma once

#include "model.h"

#include <QOpenGLFunctions_4_5_Core>
#include <QOpenGLShaderProgram>
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
    void initShader(QOpenGLShaderProgram& shader);

    Model* m_model{ nullptr };
    // 着色器变量
    QOpenGLShaderProgram m_lightShader;

signals:
};
