using BinDeps

@BinDeps.setup

path = dirname(@__FILE__)

libbouknap = library_dependency("libbouknap")
libminknap = library_dependency("libminknap")

pisinger_webpage_uri = "http://hjemmesider.diku.dk/~pisinger"

pisinger_files_root = "$path/../libpisinger"
lib_pisinger_root = "$path/libpisinger"
lib_pisinger_minknap= "$lib_pisinger_root/minknap"
lib_minknap_build = "$lib_pisinger_minknap/build"
lib_pisinger_bouknap = "$lib_pisinger_root/bouknap"
lib_bouknap_build = "$lib_pisinger_bouknap/build"

# Copy extra source code in deps folder
run(`cp -r $pisinger_files_root .`)

provides(SimpleBuild,
    (@build_steps begin
        FileDownloader("$pisinger_webpage_uri/bouknap.c", "$lib_pisinger_bouknap/bouknap.c")
        `sed -i '' '/values\.h/d' $lib_pisinger_bouknap/bouknap.c` # Removing deprecated headers
        `sed -i '' '/malloc\.h/d' $lib_pisinger_bouknap/bouknap.c`
        CreateDirectory(lib_bouknap_build)
        @build_steps begin
            ChangeDirectory(lib_bouknap_build)
            `cmake ..`
            `make`
        end
    end), libbouknap)

provides(SimpleBuild,
    (@build_steps begin
        FileDownloader("$pisinger_webpage_uri/minknap.c", "$lib_pisinger_minknap/minknap.c")
        `sed -i '' '/values\.h/d' $lib_pisinger_minknap/minknap.c`
        `sed -i '' '/malloc\.h/d' $lib_pisinger_minknap/minknap.c`
        CreateDirectory(lib_minknap_build)
        @build_steps begin
            ChangeDirectory(lib_minknap_build)
            `cmake ..`
            `make`
        end
    end), libminknap)

@BinDeps.install Dict(:libbouknap => :_jl_libbouknap,
                      :libminknap => :_jl_libminknap)
