#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <stdio.h>

#include "moonbit.h"

// 声明 Zig 导出的函数
extern char* zig_http_get(const char* url);
extern char* zig_http_post(const char* url, const char* body);
extern char* zig_http_put(const char* url, const char* body);
extern char* zig_http_delete(const char* url);

char* moonbit_string_to_c_str(const moonbit_string_t* str) {
    int32_t const len = Moonbit_array_length(str);

    if (!str || len == 0) {
        return NULL;
    }

    const uint16_t* chars = (const uint16_t*)str;
    char* result = malloc(len + 1);
    if (!result) {
        return NULL;
    }
    
    for (int32_t i = 0; i < len; i++) {
        result[i] = (char)chars[i];
    }

    result[len] = '\0';
    
    return result;
}

moonbit_string_t c_str_to_moonbit_string(const char* str) {
    if (!str) {
        return NULL;
    }
    
    size_t len = strlen(str);
    moonbit_string_t result = moonbit_make_string(len, 0);

    if (!result) {
        return NULL;
    }
    
    for (size_t i = 0; i < len; i++) {
        result[i] = str[i];
    }
    
    return result;
}

moonbit_string_t curl_get(const moonbit_string_t* url) {
    char* c_url = moonbit_string_to_c_str(url);
    if (!c_url) {
        return NULL;
    }
    
    char* response = zig_http_get(c_url);
    free(c_url);
    
    moonbit_string_t result = c_str_to_moonbit_string(response);
    free(response);
    return result;
}

moonbit_string_t curl_post(const moonbit_string_t* url, const moonbit_string_t* body) {
    char* c_url = moonbit_string_to_c_str(url);
    char* c_body = moonbit_string_to_c_str(body);
    if (!c_url || !c_body) {
        free(c_url);
        free(c_body);
        return NULL;
    }
    
    char* response = zig_http_post(c_url, c_body);
    free(c_url);
    free(c_body);
    
    moonbit_string_t result = c_str_to_moonbit_string(response);
    free(response);
    return result;
}

moonbit_string_t curl_put(const moonbit_string_t* url, const moonbit_string_t* body) {
    char* c_url = moonbit_string_to_c_str(url);
    char* c_body = moonbit_string_to_c_str(body);
    if (!c_url || !c_body) {
        free(c_url);
        free(c_body);
        return NULL;
    }
    
    char* response = zig_http_put(c_url, c_body);
    free(c_url);
    free(c_body);
    
    moonbit_string_t result = c_str_to_moonbit_string(response);
    free(response);
    return result;
}

moonbit_string_t curl_delete(const moonbit_string_t* url) {
    char* c_url = moonbit_string_to_c_str(url);
    if (!c_url) {
        return NULL;
    }
    
    char* response = zig_http_delete(c_url);
    free(c_url);
    
    moonbit_string_t result = c_str_to_moonbit_string(response);
    free(response);
    return result;
}
