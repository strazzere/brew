require 'formula'

class Rrdtool < Formula
  homepage 'http://oss.oetiker.ch/rrdtool/index.en.html'
  url 'http://oss.oetiker.ch/rrdtool/pub/rrdtool-1.4.7.tar.gz'
  sha1 'faab7df7696b69f85d6f89dd9708d7cf0c9a273b'

  option 'lua', "Compile with lua support"

  depends_on 'glib'
  depends_on 'pango'

  # Can use lua if it is found, but don't force users to install
  # TODO: Do something here
  depends_on 'lua' => :optional if build.include? "lua"

  # Ha-ha, but sleeping is annoying when running configure a lot
  def patches; DATA; end

  def install
    ENV.libxml2

    which_perl = which 'perl'
    which_ruby = which 'ruby'
    ruby_path  = "/System/Library/Frameworks/Ruby.framework/Versions/1.8/usr/bin/ruby"

    opoo "Using system Ruby. RRD module will be installed to /Library/Ruby/..." if which_ruby.realpath.to_s == ruby_path
    opoo "Using system Perl. RRD module will be installed to /Library/Perl/..." if which_perl.to_s == "/usr/bin/perl"

    args = %W[
      --disable-dependency-tracking
      --prefix=#{prefix}
    ]
    args << "--enable-perl-site-install" if which_perl.to_s == "/usr/bin/perl"
    args << "--enable-ruby-site-install" if which_ruby.realpath.to_s == ruby_path

    system "./configure", *args

    # Needed to build proper Ruby bundle
    ENV["ARCHFLAGS"] = MacOS.prefer_64_bit? ? "-arch x86_64" : "-arch i386"

    system "make install"
    prefix.install "bindings/ruby/test.rb"
  end

  def test
    mktemp do
      system "#{bin}/rrdtool", "create", "temperature.rrd", "--step", "300", "DS:temp:GAUGE:600:-273:5000", "RRA:AVERAGE:0.5:1:1200", "RRA:MIN:0.5:12:2400", "RRA:MAX:0.5:12:2400", "RRA:AVERAGE:0.5:12:2400"
      system "#{bin}/rrdtool", "dump", "temperature.rrd"
    end
  end
end

__END__
diff --git a/configure b/configure
index 7487ad2..e7b85c1 100755
--- a/configure
+++ b/configure
@@ -31663,18 +31663,6 @@ $as_echo_n "checking in... " >&6; }
 { $as_echo "$as_me:$LINENO: result: and out again" >&5
 $as_echo "and out again" >&6; }

-echo $ECHO_N "ordering CD from http://tobi.oetiker.ch/wish $ECHO_C" 1>&6
-sleep 1
-echo $ECHO_N ".$ECHO_C" 1>&6
-sleep 1
-echo $ECHO_N ".$ECHO_C" 1>&6
-sleep 1
-echo $ECHO_N ".$ECHO_C" 1>&6
-sleep 1
-echo $ECHO_N ".$ECHO_C" 1>&6
-sleep 1
-{ $as_echo "$as_me:$LINENO: result:  just kidding ;-)" >&5
-$as_echo " just kidding ;-)" >&6; }
 echo
 echo "----------------------------------------------------------------"
 echo "Config is DONE!"
