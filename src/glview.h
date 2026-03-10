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
    virtual void initializeGL() override;
    virtual void resizeGL(int w, int h) override;
    virtual void paintGL() override;

private:
    void initShader(QOpenGLShaderProgram& shader);

    Model* m_model{ nullptr };
    // 着色器变量
    QOpenGLShaderProgram m_lightShader;

signals:
};
