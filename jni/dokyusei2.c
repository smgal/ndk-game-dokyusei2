
////////////////////////////////////////////////////////////////////////////////
//

#include <zip.h>
#include <zipint.h>
#include <jni.h>
#include <android/log.h>
#include <android/bitmap.h>

#include <stdio.h>
#include <stdlib.h>
#include <math.h>

////////////////////////////////////////////////////////////////////////////////
//

#define  LOG_TAG    "libdokyusei2"
#define  LOGI(...)  __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)
#define  LOGE(...)  __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)

////////////////////////////////////////////////////////////////////////////////
//

char g_package_name[1024] = {0};
struct zip* g_p_zip_file;

////////////////////////////////////////////////////////////////////////////////
//

void g_printLog(const char* sz_log)
{
	LOGI("%s", sz_log);
}

int g_fileExists(const char* sz_file_name)
{
	if (g_p_zip_file != NULL)
	{
		int result = zip_name_locate(g_p_zip_file, sz_file_name, 0);
		return (result != -1) ? 1 : 0;
	}

	return 0;
}

FILE* g_fileOpen(const char* sz_file_name, unsigned int* out_start_offset, unsigned int* out_length)
{
	struct zip_file* p_zip_file = zip_fopen(g_p_zip_file, sz_file_name, 0);

	if (p_zip_file)
	{
		FILE* p_file = NULL;

		if (out_start_offset)
			*out_start_offset = p_zip_file->fpos;

		if (out_length)
			*out_length = p_zip_file->bytes_left;

		zip_fclose(p_zip_file);

		p_file = fopen(g_package_name, "rb");
		fseek(p_file, p_zip_file->fpos, SEEK_SET);

		return p_file;
	}
	else
	{
		return NULL;
	}

}

typedef struct zip_file zip_file;

void g_createBufferFromCompressedFile(const char* sz_file_name, unsigned char** out_p_buffer, unsigned int* out_buffer_length)
{
	if (out_p_buffer)
	{
		*out_p_buffer = NULL;

		zip_file* p_file = zip_fopen(g_p_zip_file, sz_file_name, 0);

		if (p_file)
		{
			unsigned int length = p_file->bytes_left;

			unsigned char* p_buffer = malloc(length);

			if (p_buffer)
			{
				zip_fread(p_file, p_buffer, length);

				*out_p_buffer = p_buffer;

				if (out_buffer_length)
					*out_buffer_length = length;
			}

			zip_fclose(p_file);
		}
	}
}

////////////////////////////////////////////////////////////////////////////////
//

extern void dokyu_glue_init(void);
extern void dokyu_glue_done(void);
extern void dokyu_glue_process(void* p_start_address, int width, int height, int bytes_per_line, int bits_per_pixel, int touch_x, int touch_y);

////////////////////////////////////////////////////////////////////////////////
//

JNIEXPORT void JNICALL Java_com_avej_dokyusei2_Dokyusei2View_initDokyusei2(JNIEnv* p_env, jobject obj, jstring sj_package_name)
{
	const char* p_buffer = (*p_env)->GetStringUTFChars(p_env, sj_package_name, 0);

	int error;
	g_p_zip_file = zip_open(p_buffer, 0, &error);

	strcpy(g_package_name, p_buffer);

	if (g_p_zip_file == NULL)
	{
		LOGE("Failed to open apk: %i", error);
	}

	(*p_env)->ReleaseStringUTFChars(p_env, sj_package_name, p_buffer);
}

JNIEXPORT void JNICALL Java_com_avej_dokyusei2_Dokyusei2View_renderDokyusei2(JNIEnv* p_env, jobject obj, jobject bitmap, jlong time_ms, jint motion_x, jint motion_y)
{
    AndroidBitmapInfo  info;
    void*              pixels;
    int                ret;
    static int         is_first = 1;

    if ((ret = AndroidBitmap_getInfo(p_env, bitmap, &info)) < 0)
    {
        LOGE("AndroidBitmap_getInfo() failed ! error=%d", ret);
        return;
    }

    if (is_first)
	{
        if (info.format != ANDROID_BITMAP_FORMAT_RGBA_8888)
        {
            LOGE("Bitmap format is not RGBA_8888 !");
            return;
        }

		dokyu_glue_init();

		is_first = 0;
    }

    if ((ret = AndroidBitmap_lockPixels(p_env, bitmap, &pixels)) < 0)
    {
        LOGE("AndroidBitmap_lockPixels() failed ! error=%d", ret);
        return;
    }

	dokyu_glue_process(pixels, info.width, info.height, info.stride, 32, motion_x, motion_y);

    AndroidBitmap_unlockPixels(p_env, bitmap);
}
