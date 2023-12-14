#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <curl/curl.h>
#include <json-c/json.h>
#include <openssl/bio.h>
#include <openssl/evp.h>
#include <openssl/buffer.h>

int handleApiResponse(const char *response);

#define INITIAL_BUFFER_SIZE 20000

char *readTokenFromFile(const char *filePath) {
    FILE *file = fopen(filePath, "r");
    if (!file) {
        perror("Error opening token file");
        return NULL;
    }

    fseek(file, 0, SEEK_END);
    long fileSize = ftell(file);
    rewind(file);

    char *token = (char *)malloc(fileSize + 1);
    if (!token) {
        perror("Memory allocation error");
        fclose(file);
        return NULL;
    }

    fread(token, 1, fileSize, file);
    fclose(file);
    token[fileSize] = '\0'; // Null-terminate the string

    return token;
}

// Function to handle the response from the server
size_t write_callback(void *contents, size_t size, size_t nmemb, void *userp)
{
    size_t realsize = size * nmemb;
    char **responseBuffer = (char **)userp;
    size_t currentLength = *responseBuffer ? strlen(*responseBuffer) : 0;

    *responseBuffer = realloc(*responseBuffer, currentLength + realsize + 1);

    if (*responseBuffer == NULL) {
        fprintf(stderr, "Memory allocation error for responseBuffer\n");
        return 0;
    }

    memcpy(*responseBuffer + currentLength, contents, realsize);
    (*responseBuffer)[currentLength + realsize] = '\0';

    return realsize;
}


// Function to encode the image data in base64
char *base64_encode(const unsigned char *input, int length) {
    BIO *bio, *b64;
    BUF_MEM *bufferPtr;
    b64 = BIO_new(BIO_f_base64());
    BIO_set_flags(b64, BIO_FLAGS_BASE64_NO_NL);
    bio = BIO_new(BIO_s_mem());
    BIO_push(b64, bio);
    BIO_write(b64, input, length);
    BIO_flush(b64);
    BIO_get_mem_ptr(b64, &bufferPtr);
    char *base64_string = (char *)malloc(bufferPtr->length + 1);
    if (base64_string) {
        memcpy(base64_string, bufferPtr->data, bufferPtr->length);
        base64_string[bufferPtr->length] = '\0';
    }
    BIO_free_all(b64);
    return base64_string;
}

// Function to convert image file to base64 encoded string
char *image_to_base64(const char *file_path) {
    FILE *image_file = fopen(file_path, "rb");
    if (!image_file) {
        perror("Error opening image file");
        return NULL;
    }
    fseek(image_file, 0, SEEK_END);
    long file_size = ftell(image_file);
    rewind(image_file);
    unsigned char *image_data = (unsigned char *)malloc(file_size);
    if (!image_data) {
        perror("Memory allocation error");
        fclose(image_file);
        return NULL;
    }
    fread(image_data, 1, file_size, image_file);
    fclose(image_file);
    char *base64_string = base64_encode(image_data, file_size);
    free(image_data);
    return base64_string;
}

// Function to perform the Vision API request
int performVisionAPIRequest(const char *base64ImageData) {
    CURL *curl;
    CURLcode res;
    struct curl_slist *headers = NULL;
    char *responseBuffer = NULL; // No initial allocation

    // JSON object construction
    struct json_object *rootObj, *requestsArray, *requestObj, *imageObj, *contentObj, *featuresArray, *featureObj;
    rootObj = json_object_new_object();
    requestsArray = json_object_new_array();
    requestObj = json_object_new_object();
    imageObj = json_object_new_object();
    contentObj = json_object_new_string(base64ImageData);
    featuresArray = json_object_new_array();
    featureObj = json_object_new_object();

    json_object_object_add(featureObj, "maxResults", json_object_new_int(100));
    json_object_object_add(featureObj, "type", json_object_new_string("FACE_DETECTION"));
    json_object_array_add(featuresArray, featureObj);

    json_object_object_add(imageObj, "content", contentObj);
    json_object_object_add(requestObj, "image", imageObj);
    json_object_object_add(requestObj, "features", featuresArray);
    json_object_array_add(requestsArray, requestObj);

    json_object_object_add(rootObj, "requests", requestsArray);

    char *json_request = strdup(json_object_to_json_string_ext(rootObj, JSON_C_TO_STRING_PLAIN));
    int detectedFaces;

    // Initialize libcurl
    curl = curl_easy_init();
    if (curl) {
        headers = curl_slist_append(headers, "Content-Type: application/json");
        headers = curl_slist_append(headers, "Accept-Charset: utf-8");
        // Add Authorization header (replace with actual token)
        char *token = readTokenFromFile("token.txt");
		if (token) {
		    char authHeader[1024];
		    snprintf(authHeader, sizeof(authHeader), "Authorization: Bearer %s", token);
		    headers = curl_slist_append(headers, authHeader);
		    free(token);
		} else {
		    // Token 읽기 실패 처리
		    return -1;
		}

        curl_easy_setopt(curl, CURLOPT_URL, "https://vision.googleapis.com/v1/images:annotate");
        curl_easy_setopt(curl, CURLOPT_HTTPHEADER, headers);
        curl_easy_setopt(curl, CURLOPT_POSTFIELDS, json_request);
        curl_easy_setopt(curl, CURLOPT_WRITEDATA, &responseBuffer);
        curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, write_callback);

        // Perform the request
        res = curl_easy_perform(curl);
            if (res != CURLE_OK) {
                fprintf(stderr, "curl_easy_perform() failed: %s\n", curl_easy_strerror(res));
                return -1;
            } else {
                detectedFaces = handleApiResponse(responseBuffer);
            }

        // Cleanup
        free(json_request);
        free(responseBuffer);
        curl_slist_free_all(headers);
        curl_easy_cleanup(curl);
    }

    json_object_put(rootObj);
    return detectedFaces;
}

// Function to handle and parse the API response
int handleApiResponse(const char *response)
{
    char *responseCopy = strdup(response); // Create a copy of the response
    if (responseCopy == NULL)
    {
        fprintf(stderr, "Memory allocation error for responseCopy\n");
        return -1;
    }

    struct json_object *root = json_tokener_parse(responseCopy);
    int peopleCount;

    if (root == NULL)
    {
        fprintf(stderr, "Error parsing JSON\n");
        free(responseCopy);
        return -1;
    }

    struct json_object *responses;
    if (json_object_object_get_ex(root, "responses", &responses))
    {
        int array_len = json_object_array_length(responses);

        for (int i = 0; i < array_len; i++)
        {
            struct json_object *responseItem = json_object_array_get_idx(responses, i);
            struct json_object *faceAnnotations;

            if (json_object_object_get_ex(responseItem, "faceAnnotations", &faceAnnotations))
            {
                peopleCount = json_object_array_length(faceAnnotations);
            }
        }
    }
    else
    {
        fprintf(stderr, "Invalid or missing 'responses' array in the JSON.\n");
        free(responseCopy);
        return -2;
    }

    free(responseCopy);
    json_object_put(root);
    return peopleCount;
}