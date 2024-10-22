#include <windows.h>
#include <urlmon.h>
#include <stdio.h>
#include <string.h>

void downloadFile(const char *url, const char *path) {
    HRESULT result = URLDownloadToFile(NULL, url, path, 0, NULL);
    if (result != S_OK) {
        fprintf(stderr, "Error downloading file from %s\n", url);
        exit(1);
    }
}

void addToPath(const char *path) {
    char currentPath[MAX_PATH];
    GetEnvironmentVariable("PATH", currentPath, MAX_PATH);

    // Check if the path is already in the PATH variable
    if (strstr(currentPath, path) == NULL) {
        // Check for the maximum length to prevent overflow
        if (strlen(currentPath) + strlen(path) + 2 < MAX_PATH) {
            strcat(currentPath, ";");
            strcat(currentPath, path);
            if (SetEnvironmentVariable("PATH", currentPath)) {
                printf("Successfully added %s to system PATH.\n", path);
            } else {
                fprintf(stderr, "Failed to set PATH environment variable. Error code: %lu\n", GetLastError());
            }
        } else {
            fprintf(stderr, "Error: PATH environment variable would exceed maximum length.\n");
        }
    } else {
        printf("%s is already in the system PATH.\n", path);
    }

    // Verify if the path was added successfully
    GetEnvironmentVariable("PATH", currentPath, MAX_PATH);
    if (strstr(currentPath, path) == NULL) {
        fprintf(stderr, "Warning: %s was not added to the PATH. Please add it manually.\n", path);
    } else {
        printf("Please verify if %s is added to your PATH after installation.\n", path);
    }
}

int main() {
    // Check for admin privileges
    if (!IsUserAnAdmin()) {
        fprintf(stderr, "This installer requires administrator privileges.\n");
        return 1;
    }

    // Define URLs and paths
    const char *neitUrl = "https://github.com/OxumLabs/neit/releases/download/0.0.38.1/neit";
    const char *tdmGccUrl = "https://github.com/jmeubank/tdm-gcc/releases/download/v1.2105.1/tdm-gcc-webdl.exe";
    const char *installDir = "C:\\Program Files\\Neit";
    const char *neitPath = "C:\\Program Files\\Neit\\neit.exe";
    const char *tdmGccPath = "C:\\Program Files\\Neit\\tdm64-gcc-10.3.0-2.exe";

    // Create the download directory
    CreateDirectory(installDir, NULL);

    // Download files
    printf("Downloading Neit...\n");
    downloadFile(neitUrl, neitPath);
    printf("Downloading TDM-GCC...\n");
    downloadFile(tdmGccUrl, tdmGccPath);

    // Add to system PATH
    addToPath(installDir);

    printf("Installation completed successfully.\n");
    return 0;
}
