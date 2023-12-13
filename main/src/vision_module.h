#ifndef VISION_MODULE_H
#define VISION_MODULE_H

// vision_module.c에서 사용하는 헤더 파일들 포함
#include <stdio.h>

// 함수 선언
int performVisionAPIRequest(const char *base64ImageData);
char *image_to_base64(const char *file_path);

#endif // VISION_MODULE_H
