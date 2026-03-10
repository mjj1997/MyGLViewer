#include "glview.h"

GLView::GLView(QWidget* parent)
    : QOpenGLWidget{ parent }
{}

GLView::~GLView()
{
    makeCurrent();
    delete m_model;
    doneCurrent();
}

void GLView::initializeGL()
{
    initializeOpenGLFunctions();
    initShader(m_lightShader);
    m_model = new Model{ this };
}

void GLView::resizeGL(int w, int h) {}

void GLView::paintGL()
{
    glClearColor(0.2f, 0.3f, 0.3f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);

    m_lightShader.bind();
    m_model->draw(m_lightShader);
    m_lightShader.release();
}

void GLView::initShader(QOpenGLShaderProgram& shader)
{
    bool result{ true };
    // 编译顶点着色器
    result = shader.addShaderFromSourceFile(QOpenGLShader::Vertex, ":/shader/1.model_loading.vert");
    if (!result) {
        qDebug() << shader.log();
    }

    // 编译片段着色器
    result = shader.addShaderFromSourceFile(QOpenGLShader::Fragment,
                                            ":/shader/1.model_loading.frag");
    if (!result) {
        qDebug() << shader.log();
    }

    // 链接着色器程序
    result = shader.link();
    if (!result) {
        qDebug() << shader.log();
    }
}
