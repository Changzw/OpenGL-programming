#include "glad.h"
#include <GLFW/glfw3.h>

#include <iostream>
#include <cmath>

void framebuffer_size_callback(GLFWwindow* window, int width, int height);
void processInput(GLFWwindow *window);

// settings
const unsigned int SCR_WIDTH = 800;
const unsigned int SCR_HEIGHT = 600;

const char *vertexShaderSource ="#version 330 core\n"
    "layout (location = 0) in vec3 aPos;\n"
    "void main()\n"
    "{\n"
    "   gl_Position = vec4(aPos, 1.0);\n"
    "}\0";

const char *fragmentShaderSource = "#version 330 core\n"
    "out vec4 FragColor;\n"
    "uniform vec4 ourColor;\n"
    "void main()\n"
    "{\n"
    "   FragColor = ourColor;\n"
    "}\n\0";

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

typedef void (APIENTRYP ISSUCCESS)(GLuint shader, GLenum pname, GLint *params);
typedef void (APIENTRYP ERRORLOG)(GLuint shader, GLsizei bufSize, GLsizei *length, GLchar *infoLog);

void checkErrors(GLuint checkThing, ISSUCCESS isSuccess, ERRORLOG errorLog, GLenum name){
  int success;
  char infoLog[512];
  isSuccess(checkThing, name, &success);
  if (!success){
    errorLog(checkThing, 512, NULL, infoLog);
    if (name == GL_COMPILE_STATUS) {
      std::cout << "ERROR::SHADER::VERTEX::COMPILATION_FAILED\n" << infoLog << std::endl;
    }else if (name == GL_LINK_STATUS) {
      std::cout << "ERROR::SHADER::VERTEX::LINK_FAILED\n" << infoLog << std::endl;
    }
  }
}

int shader(GLenum type, GLsizei count, const GLchar *const*string, const GLint *length){
  int shader = glCreateShader(type);
  glShaderSource(shader, count, string, NULL);
  glCompileShader(shader);
  checkErrors(shader, glGetShaderiv, glGetShaderInfoLog, GL_COMPILE_STATUS);
  return shader;
}

int linkShaders(GLuint vertexShader, GLuint fragmentShader) {
  int shaderProgram = glCreateProgram();
  glAttachShader(shaderProgram, vertexShader);
  glAttachShader(shaderProgram, fragmentShader);
  glLinkProgram(shaderProgram);
  checkErrors(shaderProgram ,glGetProgramiv, glGetProgramInfoLog, GL_LINK_STATUS);
  return shaderProgram;
}

unsigned int *vao_vbo() {
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
  unsigned int result[2] = {VAO, VBO};
  unsigned int *t = result;
  return t;
}

void renderLoop(GLFWwindow* window, GLuint shaderProgram, int vao, int vbo, int ebo) {
   while (!glfwWindowShouldClose(window)){
     // input
     // -----
     processInput(window);
     
     // render
     // ------
     glClearColor(0.2f, 0.3f, 0.3f, 1.0f);
     glClear(GL_COLOR_BUFFER_BIT);
     
     // be sure to activate the shader before any calls to glUniform
     glUseProgram(shaderProgram);
     
     // update shader uniform
     float timeValue = glfwGetTime();
     float greenValue = sin(timeValue) / 2.0f + 0.5f;
     int vertexColorLocation = glGetUniformLocation(shaderProgram, "ourColor");
     glUniform4f(vertexColorLocation, 0.0f, greenValue, 0.0f, 1.0f);
     
     // render the triangle
     glDrawArrays(GL_TRIANGLES, 0, 3);
     
     // glfw: swap buffers and poll IO events (keys pressed/released, mouse moved etc.)
     // -------------------------------------------------------------------------------
     glfwSwapBuffers(window);
     glfwPollEvents();
   }
}

int main(){
  // glfw window creation
  GLFWwindow* window = createWindow();
  if (window == NULL) return -1;
  // glad: load all OpenGL function pointers
  if (loadFunctions() == -1) return -1;

  // vertex shader
  int vertexShader = shader(GL_VERTEX_SHADER, 1, &vertexShaderSource, NULL);
  // fragment shader
  int fragmentShader = shader(GL_FRAGMENT_SHADER, 1, &fragmentShaderSource, NULL);
  // link shaders
  int shaderProgram = linkShaders(vertexShader, fragmentShader);
  glDeleteShader(vertexShader);
  glDeleteShader(fragmentShader);
  
  // set up vertex data (and buffer(s)) and configure vertex attributes
  unsigned int VBO, VAO;
  unsigned int *vertexData = vao_vbo();
  VBO = vertexData[0];
  VAO = vertexData[1];
  // You can unbind the VAO afterwards so other VAO calls won't accidentally modify this VAO, but this rarely happens. Modifying other
  // VAOs requires a call to glBindVertexArray anyways so we generally don't unbind VAOs (nor VBOs) when it's not directly necessary.
  // glBindVertexArray(0);
  
  // bind the VAO (it was already bound, but just to demonstrate): seeing as we only have a single VAO we can
  // just bind it beforehand before rendering the respective triangle; this is another approach.
  glBindVertexArray(VAO);

  // render loop
  renderLoop(window, shaderProgram, VAO, VBO, NULL);
  
  // optional: de-allocate all resources once they've outlived their purpose:
  glDeleteVertexArrays(1, &VAO);
  glDeleteBuffers(1, &VBO);
  
  // glfw: terminate, clearing all previously allocated GLFW resources.
  glfwTerminate();
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
