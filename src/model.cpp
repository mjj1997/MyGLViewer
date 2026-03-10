#include "model.h"

Model::Model(QOpenGLFunctions_4_5_Core* glFunc)
    : m_glFunc(glFunc)
    , m_VBO(QOpenGLBuffer::VertexBuffer)
    , m_EBO(QOpenGLBuffer::IndexBuffer)
{}

Model::~Model()
{
    m_VAO.destroy();
    m_VBO.destroy();
    m_EBO.destroy();
}

void Model::draw(QOpenGLShaderProgram& shader)
{
    // 创建 VAO, VBO, EBO
    if (!m_VAO.isCreated()) {
        m_VAO.create();
    } else {
        m_VAO.release();
    }

    if (!m_VBO.isCreated()) {
        m_VBO.create();
    } else {
        m_VBO.release();
    }

    if (!m_EBO.isCreated()) {
        m_EBO.create();
    } else {
        m_EBO.release();
    }

    // 绑定 VAO, VBO, EBO
    QOpenGLVertexArrayObject::Binder vaoBinder(&m_VAO);

    m_VBO.bind();
    m_VBO.allocate(vertices, sizeof(vertices));

    m_EBO.bind();
    m_EBO.allocate(indices, sizeof(indices));

    // 设置顶点属性指针
    // 顶点位置
    m_glFunc->glEnableVertexAttribArray(0);
    m_glFunc->glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 6 * sizeof(float), (void*) 0);
    // 顶点法线
    m_glFunc->glEnableVertexAttribArray(1);
    m_glFunc->glVertexAttribPointer(1,
                                    3,
                                    GL_FLOAT,
                                    GL_FALSE,
                                    6 * sizeof(float),
                                    (void*) (3 * sizeof(float)));

    // 绘制元素
    shader.setUniformValue("objectColor", 1.f, 0.2f, 0.2f, 1.f);
    m_glFunc->glDrawElements(GL_TRIANGLES, sizeof(indices), GL_UNSIGNED_INT, 0);
}
