//
//  RenderView.m
//  OpenGL三角形
//
//  Created by zkzk on 2018/9/11.
//  Copyright © 2018年 1707002. All rights reserved.
//
#import "RenderView.h"
#import <OpenGLES/ES3/gl.h>

@interface RenderView()
{
    GLuint _renderBuffer;
    GLuint _frameBuffer;
    GLuint _programe;
}

@property (nonatomic, strong) CAEAGLLayer *eaglLayer;

@property (nonatomic, strong) EAGLContext *eaglContext;

@end

@implementation RenderView
+ (Class)layerClass{
    return [CAEAGLLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self initEveryThing];
    }
    return self;
}

- (void)initEveryThing{
    [self initEaglLayer];
    [self initEaglContext];
    [self deleteBuffer];
    [self initRenderBuffer];
    [self initFrameBuffer];
//    [self renderLayer];
}

- (void)initEaglLayer{
    self.eaglLayer = (CAEAGLLayer*)self.layer;
    [self setContentScaleFactor:[UIScreen mainScreen].scale];
    self.eaglLayer.opaque = YES;
    self.eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:false],kEAGLDrawablePropertyRetainedBacking,kEAGLColorFormatRGBA8,kEAGLDrawablePropertyColorFormat,nil];
}

- (void)initEaglContext{
    EAGLContext* context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if (!context) {
        NSLog(@"create context is failed ");
        return;
    }
    self.eaglContext = context;
    if (![EAGLContext setCurrentContext:self.eaglContext]) {
        NSLog(@"set context is failed ");
    }
}

- (void)initRenderBuffer{
    glGenRenderbuffers(1, &_renderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
    
    /* Attaches an EAGLDrawable as storage for the OpenGL ES renderbuffer object bound to <target> */
    // 给opengles rendebuffer 对象关联的目标对象设置一个EAGLDrawable 作为存储对象
    // 参数1 绑定的renderbuffer 关联对象 用来管理所有render的数据
    //id<EAGLDrawable> 遵守该协议的任意对象 CAEAGLLayer 就遵守了该协议 指定画布是那一块
    [self.eaglContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:self.eaglLayer];
}

- (void)initFrameBuffer{
    // 创建
    glGenFramebuffers(1, &_frameBuffer);
    //绑定
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    //关联renderbuffer
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _renderBuffer);
}

- (void)deleteBuffer{
    if (_renderBuffer) {
        glDeleteRenderbuffers(1, &_renderBuffer);
        _renderBuffer = 0;
    }
    if (_frameBuffer) {
        glDeleteFramebuffers(1, &_frameBuffer);
        _frameBuffer = 0;
    }
}

- (void)layoutSubviews{
    [self renderLayer];
}

// 开始绘制
- (void)renderLayer{
    //1. 编译着色器程序(顶点着色器 片元着色器, programe)
    NSString* vertexPath = [[NSBundle mainBundle] pathForResource:@"vertex.vsh" ofType:nil];
    NSString* fragPath = [[NSBundle mainBundle] pathForResource:@"frag.fsh" ofType:nil];
    GLuint vertexShder = [self initializeShader:GL_VERTEX_SHADER filePath:vertexPath];
    GLuint fragShder = [self initializeShader:GL_FRAGMENT_SHADER filePath:fragPath];
    
    if (vertexShder == 0||fragShder == 0) {
        return;
    }
    GLuint program = [self compileShader:fragShder andVertex:vertexShder];
    if (program == 0) {
        return;
    }
    _programe = program;

    int posLocation = glGetAttribLocation(_programe, "position");
    int texCoordPos = glGetAttribLocation(_programe, "texcoord");
    // 设置顶点数据
    GLfloat vertices[] = {
        -0.5,-0.5,0,0,0,//左
        0.5,-0.5,0,1,0,//右
        -0.5,0.5,0,0,1,//上
        
        -0.5,0.5,0,0,1,//写上所有顶底
        0.5,-0.5,0,1,0,
        0.5,0.5,0,1,1
    };
    
    //2. 创建VAO VBO
     GLuint VBO, VAO ;
    GLuint textId;
    // 首先分配VAO 分配VBO
    glGenVertexArrays(1, &VAO);
    glGenBuffers(1, &VBO);
    glGenTextures(1, &textId);
    
    // 首先绑定VAO然后设置VBO 以及各项属性
    glBindVertexArray(VAO);
    
    // 绑定VBO 这样操作GL_ARRAY_BUFFER 就能设置VBO的各项属性
    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    //上传数据
    /*
     参数1: 上传数据给谁
     参数2: 上传数据个数
     参数3: 起始位置
     参数4: 绘制方式
     */
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    
    //让顶点开启 并且设置告诉它以什么样的方式去读取GPU内部的顶点数据
    glEnableVertexAttribArray(posLocation);
    
    /*
     参数1 需要配置哪个顶点的属性值
     参数2 顶点属性的大小 顶点属性是一个vec3组成的 由3个值组成所以大小是3  也就是一次读取几个数值
     参数3 顶点数据的类型
     参数4 是否归一化 如果设置true 就所有的数据都会被映射到0到1之间
     参数5 步长 间隔几个读一次 这里步长是3
     参数6 起始偏移量
     */
    glVertexAttribPointer(posLocation, 3, GL_FLOAT, GL_FALSE, 5*sizeof(GLfloat), (GLvoid*)0);
    
    glEnableVertexAttribArray(texCoordPos);
    glVertexAttribPointer(texCoordPos, 2, GL_FLOAT, GL_FALSE, 5*sizeof(GLfloat), (GLvoid*)3);
    
    [self loadTexture:[UIImage imageNamed:@"img.jpg"] textId:textId];
    // 解绑
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindVertexArray(0);// 为了防止奇怪的错误出现,解绑buffer总是一个好习惯
    
    // 设置视口
    CGSize screen_size = [UIScreen mainScreen].bounds.size;
    CGFloat scale = [UIScreen mainScreen].scale;
    glViewport(0, screen_size.width, screen_size.width*scale, screen_size.width*scale);
    
    // 设置清屏颜色值
    glClearColor(0.2, 0.3, 0.5, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glUseProgram(_programe);
    glBindVertexArray(VAO);
    glDrawArrays(GL_TRIANGLES, 0, 6);
    glBindVertexArray(0);
    
    // 展示目标buffer
    [self.eaglContext presentRenderbuffer:GL_RENDERBUFFER];
}

- (void)loadTexture:(UIImage*)uiimg textId:(GLuint)texId{
  
    CGImageRef cgImg = uiimg.CGImage;
    size_t imageWidth = CGImageGetWidth(cgImg);
    size_t imageHeight = CGImageGetHeight(cgImg);
    
    //获取图片字节数
    GLubyte* dateByte = (GLubyte*)calloc(imageWidth*imageHeight*4, sizeof(GLubyte));
    
    CGContextRef context = CGBitmapContextCreate(dateByte, imageWidth, imageHeight, 8, imageWidth*4,CGImageGetColorSpace(cgImg), kCGImageAlphaPremultipliedLast);
    
    CGContextDrawImage(context, CGRectMake(0, 0, imageWidth, imageHeight), cgImg);
    CGContextRelease(context);
    
    glBindTexture(GL_TEXTURE_2D, texId);
    //设置纹理属性
    /*
     参数1：纹理维度
     参数2：线性过滤、为s,t坐标设置模式
     参数3：wrapMode,环绕模式
     */
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (float)imageWidth, (float)imageHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE,dateByte );
    free(dateByte);
}

- (GLuint)initializeShader:(GLuint)shaderType filePath:(NSString*)filePath{
    
    GLuint shader = glCreateShader(shaderType);
    NSError * error = nil;
    NSString* fileContext = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        NSLog(@"error is = %@",error.localizedDescription);
        return 0;
    }
    const char* fileChar = [fileContext UTF8String];
    glShaderSource(shader, 1, &fileChar, NULL);
    glCompileShader(shader);
    
    GLint success;
    GLchar infoLog[1024];
    glGetShaderiv(shader, GL_COMPILE_STATUS, &success);
    if (!success) {
        glGetShaderInfoLog(shader, 1024, NULL, infoLog);
        NSLog(@"error str is = %s",infoLog);
        return 0;
    }
    
    return shader;
}

- (GLuint)compileShader:(GLuint)fragShader andVertex:(GLuint)vertexShder{
    
    GLuint program = glCreateProgram();
    
    // 关键着色器
    glAttachShader(program, vertexShder);
    glAttachShader(program, fragShader);
    
    // link
    glLinkProgram(program);
    
    // 判断是否成功
    GLint success;
    GLchar infoLog[1024] ;
    glGetProgramiv(program, GL_LINK_STATUS, &success);
    
    if (!success) {
        glGetProgramInfoLog(program, 1024, NULL, infoLog);
        NSLog(@"%s",infoLog);
        return 0;
    }
    
    //成功
    glDeleteShader(vertexShder);
    glDeleteShader(fragShader);
    return program;
}

@end
