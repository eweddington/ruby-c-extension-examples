require 'mkmf'

# NOTE! Adjust this constant to match the name of the Init_*() function.
EXTENSION_NAME = 'SUEX_HelloBox'.freeze

PLATFORM_IS_OSX     = (Object::RUBY_PLATFORM =~ /darwin/i) ? true : false
PLATFORM_IS_WINDOWS = !PLATFORM_IS_OSX

# Default mkmf cflags configuration:
$CFLAGS = ''
optflags   = '$(optflags)'    # optflags = -O3 -fno-fast-math
debugflags = '$(debugflags)'  # debugflags = -ggdb3
warnflags  = '$(warnflags)'

if PLATFORM_IS_OSX
  # OSX Compile Information
  # http://forums.sketchucation.com/viewtopic.php?f=180&t=28673

  # Must be compiled into flat namespace. Otherwise SketchUp Bugsplats when it
  # tries to load the extension - while standard Ruby will not.
  unless CONFIG['LDSHARED'].include?('-flat_namespace')
    CONFIG['LDSHARED'] << ' -flat_namespace'
  end
end

# Optimize for performance.
case CONFIG['CC']
when '/usr/bin/clang'
  # http://stackoverflow.com/a/5087307/486990
  #optflags = '-O4 -ffast-math'
when 'gcc'
  # http://gcc.gnu.org/onlinedocs/gcc/Warning-Options.html#Warning-Options
  # http://gcc.gnu.org/onlinedocs/gcc/Optimize-Options.html
  #optflags = '-Ofast'
end

# Configure some extra warnings that -Wall and -Wextra doesn't enable.
warnflags += ' -Wshadow -Wconversion'

# Matches original $CFLAGS configuration.
cflags = "#{optflags} #{debugflags} #{warnflags}"
$CFLAGS = "#{cflags} -fno-common -pipe"

# Visual Studio C++ 2010 doesn't include a round() function in <math.h> This
# check will enable a HAVE_ROUND preprocessor constant.
have_func( 'round', 'math.h' )

# Configure SLAPI. Default location is a 'SLAPI' folder under the user folder
# with the OSX and Windows SLAPI packages extracted.
#
# %HOME%
# + SLAPI
#   + SketchUp-SDK-Mac
#   + SketchUp-SDK-Win

# TODO: This path is currently not configurable.
slapi_root = File.join(ENV['HOME'], 'SLAPI')
if PLATFORM_IS_OSX
  slapi_osx       = File.join(slapi_root, 'SketchUp-SDK-Mac')
  slapi_framework = File.join(slapi_osx, 'slapi.framework')
  slapi_resources = File.join(slapi_framework, 'Versions', 'A')
  slapi_headers   = File.join(slapi_resources, 'Headers')
  slapi_libs      = File.join(slapi_resources, 'Libraries')

  $CFLAGS << " -F#{slapi_osx}"

  $LDFLAGS << ' -framework slapi'
  $LDFLAGS << " -F#{slapi_osx}"

  # For some reason the SLAPI libs are not found even though the headers are.
  # This will make the linker find them.
  dir_config('slapi', nil, slapi_libs)

  have_framework('slapi') or raise 'SLAPI framework not found!'
else
  # (!) Untested!
  slapi_win     = File.join(slapi_root, 'SketchUp-SDK-Win')
  slapi_headers = File.join(slapi_win, 'Headers')
  slapi_libs    = File.join(slapi_win, 'binaries', 'x86')

  dir_config('slapi', slapi_headers, slapi_libs)
end

have_header('slapi/slapi.h') or raise 'SLAPI header not found!'

# Everything should now be set up and good to go!

#puts "CFLAGS:  #{$CFLAGS.inspect}"
#puts "LDFLAGS: #{$LDFLAGS.inspect}"

create_makefile( EXTENSION_NAME )
