#include "stub_internal.h"

// ============================================================================
// Resource destructor: FilePathList
// ============================================================================

typedef struct {
  FilePathList list;
  int freed;
  int is_dropped; // 1 = from LoadDroppedFiles, 0 = from LoadDirectoryFiles*
} FilePathListWrapper;

static void
file_path_list_destructor(void *ptr) {
  FilePathListWrapper *w = (FilePathListWrapper *)ptr;
  if (!w->freed) {
    if (w->is_dropped)
      UnloadDroppedFiles(w->list);
    else
      UnloadDirectoryFiles(w->list);
    w->freed = 1;
  }
}

// ============================================================================
// File system: Queries
// ============================================================================

int
moonbit_raylib_file_exists(moonbit_bytes_t fileName) {
  return (int)FileExists((const char *)fileName);
}

int
moonbit_raylib_directory_exists(moonbit_bytes_t dirPath) {
  return (int)DirectoryExists((const char *)dirPath);
}

int
moonbit_raylib_is_file_extension(moonbit_bytes_t fileName, moonbit_bytes_t ext) {
  return (int)IsFileExtension((const char *)fileName, (const char *)ext);
}

int
moonbit_raylib_get_file_length(moonbit_bytes_t fileName) {
  return GetFileLength((const char *)fileName);
}

moonbit_bytes_t
moonbit_raylib_get_file_extension(moonbit_bytes_t fileName) {
  const char *result = GetFileExtension((const char *)fileName);
  if (!result) {
    moonbit_bytes_t r = moonbit_make_bytes(1, 0);
    ((char *)r)[0] = '\0';
    return r;
  }
  int len = strlen(result);
  moonbit_bytes_t r = moonbit_make_bytes(len + 1, 0);
  memcpy(r, result, len + 1);
  return r;
}

moonbit_bytes_t
moonbit_raylib_get_file_name(moonbit_bytes_t filePath) {
  const char *result = GetFileName((const char *)filePath);
  if (!result) {
    moonbit_bytes_t r = moonbit_make_bytes(1, 0);
    ((char *)r)[0] = '\0';
    return r;
  }
  int len = strlen(result);
  moonbit_bytes_t r = moonbit_make_bytes(len + 1, 0);
  memcpy(r, result, len + 1);
  return r;
}

moonbit_bytes_t
moonbit_raylib_get_file_name_without_ext(moonbit_bytes_t filePath) {
  const char *result = GetFileNameWithoutExt((const char *)filePath);
  if (!result) {
    moonbit_bytes_t r = moonbit_make_bytes(1, 0);
    ((char *)r)[0] = '\0';
    return r;
  }
  int len = strlen(result);
  moonbit_bytes_t r = moonbit_make_bytes(len + 1, 0);
  memcpy(r, result, len + 1);
  return r;
}

moonbit_bytes_t
moonbit_raylib_get_directory_path(moonbit_bytes_t filePath) {
  const char *result = GetDirectoryPath((const char *)filePath);
  if (!result) {
    moonbit_bytes_t r = moonbit_make_bytes(1, 0);
    ((char *)r)[0] = '\0';
    return r;
  }
  int len = strlen(result);
  moonbit_bytes_t r = moonbit_make_bytes(len + 1, 0);
  memcpy(r, result, len + 1);
  return r;
}

moonbit_bytes_t
moonbit_raylib_get_prev_directory_path(moonbit_bytes_t dirPath) {
  const char *result = GetPrevDirectoryPath((const char *)dirPath);
  if (!result) {
    moonbit_bytes_t r = moonbit_make_bytes(1, 0);
    ((char *)r)[0] = '\0';
    return r;
  }
  int len = strlen(result);
  moonbit_bytes_t r = moonbit_make_bytes(len + 1, 0);
  memcpy(r, result, len + 1);
  return r;
}

moonbit_bytes_t
moonbit_raylib_get_working_directory(void) {
  const char *result = GetWorkingDirectory();
  if (!result) {
    moonbit_bytes_t r = moonbit_make_bytes(1, 0);
    ((char *)r)[0] = '\0';
    return r;
  }
  int len = strlen(result);
  moonbit_bytes_t r = moonbit_make_bytes(len + 1, 0);
  memcpy(r, result, len + 1);
  return r;
}

moonbit_bytes_t
moonbit_raylib_get_application_directory(void) {
  const char *result = GetApplicationDirectory();
  if (!result) {
    moonbit_bytes_t r = moonbit_make_bytes(1, 0);
    ((char *)r)[0] = '\0';
    return r;
  }
  int len = strlen(result);
  moonbit_bytes_t r = moonbit_make_bytes(len + 1, 0);
  memcpy(r, result, len + 1);
  return r;
}

int
moonbit_raylib_make_directory(moonbit_bytes_t dirPath) {
  return MakeDirectory((const char *)dirPath);
}

int
moonbit_raylib_change_directory(moonbit_bytes_t dir) {
  return (int)ChangeDirectory((const char *)dir);
}

int
moonbit_raylib_is_path_file(moonbit_bytes_t path) {
  return (int)IsPathFile((const char *)path);
}

int
moonbit_raylib_is_file_name_valid(moonbit_bytes_t fileName) {
  return (int)IsFileNameValid((const char *)fileName);
}

// ============================================================================
// File system: Data load/save
// ============================================================================

moonbit_bytes_t
moonbit_raylib_load_file_data(moonbit_bytes_t fileName) {
  int dataSize = 0;
  unsigned char *data = LoadFileData((const char *)fileName, &dataSize);
  if (!data) return moonbit_make_bytes(0, 0);
  moonbit_bytes_t result = moonbit_make_bytes(dataSize, 0);
  memcpy(result, data, dataSize);
  UnloadFileData(data);
  return result;
}

int
moonbit_raylib_save_file_data(moonbit_bytes_t fileName, moonbit_bytes_t data, int dataSize) {
  return (int)SaveFileData((const char *)fileName, (void *)data, dataSize);
}

moonbit_bytes_t
moonbit_raylib_load_file_text(moonbit_bytes_t fileName) {
  char *text = LoadFileText((const char *)fileName);
  if (!text) {
    moonbit_bytes_t r = moonbit_make_bytes(1, 0);
    ((char *)r)[0] = '\0';
    return r;
  }
  int len = strlen(text);
  moonbit_bytes_t r = moonbit_make_bytes(len + 1, 0);
  memcpy(r, text, len + 1);
  UnloadFileText(text);
  return r;
}

int
moonbit_raylib_save_file_text(moonbit_bytes_t fileName, moonbit_bytes_t text) {
  return (int)SaveFileText((const char *)fileName, (char *)text);
}

int
moonbit_raylib_export_data_as_code(moonbit_bytes_t data, int dataSize, moonbit_bytes_t fileName) {
  return (int)ExportDataAsCode((const unsigned char *)data, dataSize, (const char *)fileName);
}

// ============================================================================
// File system: File drop
// ============================================================================

int
moonbit_raylib_is_file_dropped(void) {
  return (int)IsFileDropped();
}

FilePathListWrapper *
moonbit_raylib_load_dropped_files(void) {
  FilePathListWrapper *w = (FilePathListWrapper *)moonbit_make_external_object(
    file_path_list_destructor, sizeof(FilePathListWrapper));
  w->list = LoadDroppedFiles();
  w->freed = 0;
  w->is_dropped = 1;
  return w;
}

void
moonbit_raylib_unload_dropped_files(FilePathListWrapper *w) {
  if (w && !w->freed) {
    UnloadDroppedFiles(w->list);
    w->freed = 1;
  }
}

// ============================================================================
// File system: Directory listing
// ============================================================================

FilePathListWrapper *
moonbit_raylib_load_directory_files(moonbit_bytes_t dirPath) {
  FilePathListWrapper *w = (FilePathListWrapper *)moonbit_make_external_object(
    file_path_list_destructor, sizeof(FilePathListWrapper));
  w->list = LoadDirectoryFiles((const char *)dirPath);
  w->freed = 0;
  w->is_dropped = 0;
  return w;
}

FilePathListWrapper *
moonbit_raylib_load_directory_files_ex(moonbit_bytes_t basePath, moonbit_bytes_t filter, int scanSubdirs) {
  FilePathListWrapper *w = (FilePathListWrapper *)moonbit_make_external_object(
    file_path_list_destructor, sizeof(FilePathListWrapper));
  w->list = LoadDirectoryFilesEx((const char *)basePath, (const char *)filter, (bool)scanSubdirs);
  w->freed = 0;
  w->is_dropped = 0;
  return w;
}

void
moonbit_raylib_unload_directory_files(FilePathListWrapper *w) {
  if (w && !w->freed) {
    UnloadDirectoryFiles(w->list);
    w->freed = 1;
  }
}

// ============================================================================
// File system: FilePathList accessors
// ============================================================================

int
moonbit_raylib_file_path_list_count(FilePathListWrapper *w) {
  return (int)w->list.count;
}

moonbit_bytes_t
moonbit_raylib_file_path_list_get(FilePathListWrapper *w, int index) {
  if (index < 0 || index >= (int)w->list.count) {
    moonbit_bytes_t r = moonbit_make_bytes(1, 0);
    ((char *)r)[0] = '\0';
    return r;
  }
  const char *path = w->list.paths[index];
  int len = strlen(path);
  moonbit_bytes_t r = moonbit_make_bytes(len + 1, 0);
  memcpy(r, path, len + 1);
  return r;
}

// ============================================================================
// File system: File mod time
// ============================================================================

int
moonbit_raylib_get_file_mod_time(moonbit_bytes_t fileName) {
  return (int)GetFileModTime((const char *)fileName);
}
