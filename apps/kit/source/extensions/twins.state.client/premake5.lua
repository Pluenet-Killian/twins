local ext = get_current_extension_info()

project_ext(ext)

repo_build.prebuild_link {
    { "twins", ext.target_dir.."/twins" },
    { "pip_archive", ext.target_dir.."/pip_archive" },
}
