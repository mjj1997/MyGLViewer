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
    m_model = new Model{ this };
}

void GLView::resizeGL(int w, int h) {}

void GLView::paintGL()
{
    glClearColor(0.2f, 0.3f, 0.3f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
}
