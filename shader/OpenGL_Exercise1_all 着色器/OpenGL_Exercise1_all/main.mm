//
//  main.m
//  OpenGL_Exercise1_all
//
//  Created by czw on 11/15/19.
//  Copyright © 2019 czw. All rights reserved.
//

#include "glad.h"
#include <GLFW/glfw3.h>
#include <iostream>
#include "PlayShader.hpp"

void framebuffer_size_callback(GLFWwindow* window, int width, int height);
void processInput(GLFWwindow *window);

// settings
const unsigned int SCR_WIDTH = 800;
const unsigned int SCR_HEIGHT = 600;

GLFWwindow* createWindow();
int loadFunctions();

// change Color
void changeColorDataConfig();
void renderChangeColor(PlayShader);

// move position
void moveDataConfig();
void renderMovePosition(PlayShader);

// exercise 3
void dataConfig();
void renderConfig(PlayShader);


/*
 Part I:  准备渲染引擎
 Part II: 准备渲染数据
 Part III:开始渲染
 */

int main(int argc, const char * argv[]) {
  GLFWwindow* window = createWindow();
  if (nullptr == window) {
    return -1;
  }
  if (loadFunctions() == -1) {
    return -1;
  }
  
  // 1.准备渲染引擎
  PlayShader shader = PlayShader("OuterShader.vs", "OuterShader.fs");
  // 2.准备渲染数据
  dataConfig();
  
  // 3.开始渲染
  while (!glfwWindowShouldClose(window)) {
    // input
    // -----
    processInput(window);
    
    renderConfig(shader);
    // glfw: swap buffers and poll IO events (keys pressed/released, mouse moved etc.)
    // -------------------------------------------------------------------------------
    glfwSwapBuffers(window);
    glfwPollEvents();
  }
  return 0;
}

void moveDataConfig(){
  float vertices[] = {
    0.5f, -0.5f, 0.0f,  // bottom right
    -0.5f, -0.5f, 0.0f,  // bottom left
    0.0f,  0.5f, 0.0f   // top
  };
  
  unsigned int VBO, VAO;
  glGenVertexArrays(1, &VAO);
  glGenBuffers(1, &VBO);
  // bind the Vertex Array Object first, then bind and set vertex buffer(s), and then configure vertex attributes(s).
  glBindVertexArray(VAO);
  
  glBindBuffer(GL_ARRAY_BUFFER, VBO);
  glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
  
  glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(float), (void*)0);
  glEnableVertexAttribArray(0);
}

void dataConfig(){
  float vertices[] = {
    0.5f, -0.5f, 0.0f,  // bottom right
    -0.5f, -0.5f, 0.0f,  // bottom left
    0.0f,  0.5f, 0.0f   // top
  };
  
  unsigned int VBO, VAO;
  glGenVertexArrays(1, &VAO);
  glGenBuffers(1, &VBO);
  // bind the Vertex Array Object first, then bind and set vertex buffer(s), and then configure vertex attributes(s).
  glBindVertexArray(VAO);
  
  glBindBuffer(GL_ARRAY_BUFFER, VBO);
  glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
  
  glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(float), (void*)0);
  glEnableVertexAttribArray(0);
}

void renderConfig(PlayShader shader){
  // render
  // ------
  glClearColor(0.2f, 0.3f, 0.3f, 1.0f);
  glClear(GL_COLOR_BUFFER_BIT);
  // be sure to activate the shader before any calls to glUniform
  shader.use();
  
  // render the triangle
  glDrawArrays(GL_TRIANGLES, 0, 3);
}

void renderMovePosition(PlayShader shader){
  // render
  // ------
  glClearColor(0.2f, 0.3f, 0.3f, 1.0f);
  glClear(GL_COLOR_BUFFER_BIT);
  
  // be sure to activate the shader before any calls to glUniform
  float timeValue = glfwGetTime();
  float offset = sin(timeValue) / 2.0f + 0.5f;
  shader.setFloat("xOffset", offset);
  shader.use();
  
  // render the triangle
  glDrawArrays(GL_TRIANGLES, 0, 3);
}

void changeColorDataConfig(){
  float vertices[] = {
    0.5f, -0.5f, 0.0f,  // bottom right
    -0.5f, -0.5f, 0.0f,  // bottom left
    0.0f,  0.5f, 0.0f   // top
  };
  
  unsigned int VBO, VAO;
  glGenVertexArrays(1, &VAO);
  glGenBuffers(1, &VBO);
  // bind the Vertex Array Object first, then bind and set vertex buffer(s), and then configure vertex attributes(s).
  glBindVertexArray(VAO);
  
  glBindBuffer(GL_ARRAY_BUFFER, VBO);
  glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
  
  glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(float), (void*)0);
  glEnableVertexAttribArray(0);
}

void renderChangeColor (PlayShader shader) {
  // render
  // ------
  glClearColor(0.2f, 0.3f, 0.3f, 1.0f);
  glClear(GL_COLOR_BUFFER_BIT);
  
  // be sure to activate the shader before any calls to glUniform
  shader.use();
  
  // update shader uniform
  float timeValue = glfwGetTime();
  float greenValue = sin(timeValue) / 2.0f + 0.5f;
  int vertexColorLocation = glGetUniformLocation(shader.ID, "ourColor");
  glUniform4f(vertexColorLocation, 0.0f, greenValue, 0.0f, 1.0f);
  
  // render the triangle
  glDrawArrays(GL_TRIANGLES, 0, 3);
}

GLFWwindow* createWindow() {
  // glfw: initialize and configure
  // ------------------------------
  glfwInit();
  glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
  glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
  glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
  
#ifdef __APPLE__
  glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE); // uncomment this statement to fix compilation on OS X
#endif
  
  // glfw window creation
  // --------------------
  GLFWwindow* window = glfwCreateWindow(SCR_WIDTH, SCR_HEIGHT, "LearnOpenGL", NULL, NULL);
  if (window == NULL){
    std::cout << "Failed to create GLFW window" << std::endl;
    glfwTerminate();
    return NULL;
  }
  glfwMakeContextCurrent(window);
  glfwSetFramebufferSizeCallback(window, framebuffer_size_callback);
  return window;
}

int loadFunctions() {
  if (!gladLoadGLLoader((GLADloadproc)glfwGetProcAddress)){
    std::cout << "Failed to initialize GLAD" << std::endl;
    return -1;
  }
  return 0;
}

// process all input: query GLFW whether relevant keys are pressed/released this frame and react accordingly
void processInput(GLFWwindow *window){
  if (glfwGetKey(window, GLFW_KEY_ESCAPE) == GLFW_PRESS)
    glfwSetWindowShouldClose(window, true);
}

// glfw: whenever the window size changed (by OS or user resize) this callback function executes
void framebuffer_size_callback(GLFWwindow* window, int width, int height) {
  // make sure the viewport matches the new window dimensions; note that width and
  // height will be significantly larger than specified on retina displays.
  glViewport(0, 0, width, height);
}
