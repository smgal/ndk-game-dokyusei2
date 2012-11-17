LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

#####################################################

SRC_LIBZIP_ROOT := libzip
SRC_LIBZIP      := \
	               $(SRC_LIBZIP_ROOT)/zip_add.c \
	               $(SRC_LIBZIP_ROOT)/zip_add_dir.c \
	               $(SRC_LIBZIP_ROOT)/zip_close.c \
	               $(SRC_LIBZIP_ROOT)/zip_delete.c \
	               $(SRC_LIBZIP_ROOT)/zip_dirent.c \
	               $(SRC_LIBZIP_ROOT)/zip_entry_free.c \
	               $(SRC_LIBZIP_ROOT)/zip_entry_new.c \
	               $(SRC_LIBZIP_ROOT)/zip_err_str.c \
	               $(SRC_LIBZIP_ROOT)/zip_error.c \
	               $(SRC_LIBZIP_ROOT)/zip_error_clear.c \
	               $(SRC_LIBZIP_ROOT)/zip_error_get.c \
	               $(SRC_LIBZIP_ROOT)/zip_error_get_sys_type.c \
	               $(SRC_LIBZIP_ROOT)/zip_error_strerror.c \
	               $(SRC_LIBZIP_ROOT)/zip_error_to_str.c \
	               $(SRC_LIBZIP_ROOT)/zip_fclose.c \
	               $(SRC_LIBZIP_ROOT)/zip_file_error_clear.c \
	               $(SRC_LIBZIP_ROOT)/zip_file_error_get.c \
	               $(SRC_LIBZIP_ROOT)/zip_file_get_offset.c \
	               $(SRC_LIBZIP_ROOT)/zip_file_strerror.c \
	               $(SRC_LIBZIP_ROOT)/zip_filerange_crc.c \
	               $(SRC_LIBZIP_ROOT)/zip_fopen.c \
	               $(SRC_LIBZIP_ROOT)/zip_fopen_index.c \
	               $(SRC_LIBZIP_ROOT)/zip_fread.c \
	               $(SRC_LIBZIP_ROOT)/zip_free.c \
	               $(SRC_LIBZIP_ROOT)/zip_get_archive_comment.c \
	               $(SRC_LIBZIP_ROOT)/zip_get_archive_flag.c \
	               $(SRC_LIBZIP_ROOT)/zip_get_file_comment.c \
	               $(SRC_LIBZIP_ROOT)/zip_get_num_files.c \
	               $(SRC_LIBZIP_ROOT)/zip_get_name.c \
		           $(SRC_LIBZIP_ROOT)/zip_memdup.c \
		           $(SRC_LIBZIP_ROOT)/zip_name_locate.c \
		           $(SRC_LIBZIP_ROOT)/zip_new.c \
		           $(SRC_LIBZIP_ROOT)/zip_open.c \
		           $(SRC_LIBZIP_ROOT)/zip_rename.c \
		           $(SRC_LIBZIP_ROOT)/zip_replace.c \
		           $(SRC_LIBZIP_ROOT)/zip_set_archive_comment.c \
		           $(SRC_LIBZIP_ROOT)/zip_set_archive_flag.c \
		           $(SRC_LIBZIP_ROOT)/zip_set_file_comment.c \
		           $(SRC_LIBZIP_ROOT)/zip_source_buffer.c \
		           $(SRC_LIBZIP_ROOT)/zip_source_file.c \
		           $(SRC_LIBZIP_ROOT)/zip_source_filep.c \
		           $(SRC_LIBZIP_ROOT)/zip_source_free.c \
		           $(SRC_LIBZIP_ROOT)/zip_source_function.c \
		           $(SRC_LIBZIP_ROOT)/zip_source_zip.c \
		           $(SRC_LIBZIP_ROOT)/zip_set_name.c \
		           $(SRC_LIBZIP_ROOT)/zip_stat.c \
		           $(SRC_LIBZIP_ROOT)/zip_stat_index.c \
		           $(SRC_LIBZIP_ROOT)/zip_stat_init.c \
		           $(SRC_LIBZIP_ROOT)/zip_strerror.c \
		           $(SRC_LIBZIP_ROOT)/zip_unchange.c \
		           $(SRC_LIBZIP_ROOT)/zip_unchange_all.c \
		           $(SRC_LIBZIP_ROOT)/zip_unchange_archive.c \
		           $(SRC_LIBZIP_ROOT)/zip_unchange_data.c

LOCAL_CFLAGS    := -DPNG_NO_READ_EXPAND

#####################################################

SRC_ROOT        := dokyusei2

SRC_FLAT_BOARD  := \
                   $(SRC_ROOT)/flat_board/pcx_decoder.cpp \
                   $(SRC_ROOT)/flat_board/target_android/file_io.cpp \
                   $(SRC_ROOT)/flat_board/target_android/input_device.cpp \
                   $(SRC_ROOT)/flat_board/target_android/system.cpp

SRC_DOKYUSEI    := \
                   $(SRC_ROOT)/dokyu/dk_main.cpp

LOCAL_MODULE    := dokyusei2 

LOCAL_SRC_FILES := $(SRC_LIBZIP) $(SRC_FLAT_BOARD) $(SRC_DOKYUSEI)
LOCAL_SRC_FILES += dokyusei2.c dokyusei2_glue.cpp

LOCAL_CFLAGS    += -DPIXELFORMAT_ABGR
LOCAL_CFLAGS    += -Ilibzip

LOCAL_LDLIBS    := -lm -llog -ljnigraphics -lz

include $(BUILD_SHARED_LIBRARY)
