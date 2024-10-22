#include <windows.h>
#include <urlmon.h>
#include <stdio.h>
#include <string.h>

void downloadFile(const char *url, const char *path) {
    HRESULT result = URLDownloadToFileA(NULL, url, path, 0, NULL);
    if (result != S_OK) {
        fprintf(stderr, "Error downloading file from %s\n", url);
        exit(1);
    }
}

void addToPath(const char *path) {
    char currentPath[MAX_PATH];
    GetEnvironmentVariableA("PATH", currentPath, MAX_PATH);

    // Ensure the path is not already in the PATH
    if (strstr(currentPath, path) == NULL) {
        strcat(currentPath, ";");
        strcat(currentPath, path);
        if (SetEnvironmentVariableA("PATH", currentPath)) {
            printf("Added %s to system PATH.\n", path);
        } else {
            fprintf(stderr, "Failed to set PATH environment variable. Error code: %lu\n", GetLastError());
        }
    } else {
        printf("%s is already in the system PATH.\n", path);
    }
}

void runInstaller(const char *installerPath) {
    printf("Running installer: %s...\n", installerPath);
    int result = (int)ShellExecuteA(NULL, "runas", installerPath, NULL, NULL, SW_SHOWNORMAL);
    if (result <= 32) {
        fprintf(stderr, "Failed to run installer. Error code: %d\n", result);
        exit(1);
    }
}

int main() {
    // Check for admin privileges
    if (!IsUserAnAdmin()) {
        fprintf(stderr, "This installer requires administrator privileges. Please run as administrator.\n");
        return 1;
    }

    // Define URLs and paths
    const char *neitUrl = "https://github.com/OxumLabs/neit/releases/download/0.0.38.1/neit";
    const char *tdmGccUrl = "https://github.com/jmeubank/tdm-gcc/releases/download/v1.2105.1/tdm-gcc-webdl.exe";
    const char *neitPath = "C:\\Program Files\\Neit\\neit.exe";
    const char *tdmGccPath = "C:\\Program Files\\Neit\\tdm64-gcc-10.3.0-2.exe";

    // Create the download directory
    if (CreateDirectoryA("C:\\Program Files\\Neit", NULL) || GetLastError() == ERROR_ALREADY_EXISTS) {
        printf("Creating download directory at C:\\Program Files\\Neit...\n");
    } else {
        fprintf(stderr, "Failed to create directory. Error code: %lu\n", GetLastError());
        return 1;
    }

    // Download files
    printf("Downloading Neit...\n");
    downloadFile(neitUrl, neitPath);
    printf("Neit downloaded successfully to %s.\n", neitPath);

    printf("Downloading TDM-GCC...\n");
    downloadFile(tdmGccUrl, tdmGccPath);
    printf("TDM-GCC downloaded successfully to %s.\n", tdmGccPath);

    // Run the TDM-GCC installer
    runInstaller(tdmGccPath);

    // Inform user about Clang preference
    printf("Note: While TDM-GCC has been installed, Clang is preferred for Neit. If you have Clang installed and it's in your PATH, Neit will use it automatically.\n");

    // Add Neit to system PATH
    addToPath("C:\\Program Files\\Neit");

    printf("Installation completed successfully.\n");
    return 0;
}
