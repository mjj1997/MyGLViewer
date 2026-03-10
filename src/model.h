#pragma once

#include <QOpenGLBuffer>
#include <QOpenGLFunctions_4_5_Core>
#include <QOpenGLShaderProgram>
#include <QOpenGLVertexArrayObject>

class Model
{
public:
    explicit Model(QOpenGLFunctions_4_5_Core* glFunc);
    ~Model();

    void draw(QOpenGLShaderProgram& shader);

private:
    // 顶点的数据
    float vertices[18] = {
        // 所有的值是在[-1, 1]之间的
        -0.5f, -0.5f, 0.0f, 0.f,  0.f,  1.f,  0.5f, -0.5f, 0.0f,
        0.f,   0.f,   1.f,  0.0f, 0.5f, 0.0f, 0.f,  0.f,   1.f
    };

    unsigned int indices[3]{ 0, 1, 2 };

    QOpenGLFunctions_4_5_Core* m_glFunc;

    QOpenGLVertexArrayObject m_VAO;
    QOpenGLBuffer m_VBO;
    QOpenGLBuffer m_EBO;
};
