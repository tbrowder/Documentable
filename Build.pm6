use v6;

use Documentable;

=begin comment
#| Standard OS directories for default config.json files.
our @default-config-dirs is export =
    '/usr/share/raku/documentable',   #| for the root user for system-wide use
    "%*ENV<HOME>/.raku/documentable", #| for a normal user
    ;

#| Directory name for the local doc repo's user config file.
our $config-user-dir is export = 'config-user';
=end comment

use File::Find;

=begin comment
# list of final locations for the default config.json
# in desired order from a global view:
my @flocs =
    '/usr/share/raku/documentable', # requires root user
    "%*ENV<HOME>/.raku/documentable"
    ;
=end comment

my $dbg = 1;

unit class Build;

method build($workdir) {
    # do build-time stuff

    # collect resources dirs and files
    my @rdirs = find :type('dir'), :dir("$workdir/resources");
    my @rfils = find :type('file'), :dir("$workdir/resources");

    # first make sure we find a writable top dir
    my $todir      = 0;

    for @default-config-dirs -> $dir {
        # use a try block so failure can be skipped
        try {
            #note "DEBUG: \$dir = $dir";
            #my $from = "$workdir/resources/config.json";
            #note "DEBUG: \$from = $from";
            my $to = "$dir/config.json";
            #my $to = "$dir";
            #note "DEBUG: \$to = $to";

            mkdir $dir if !$dir.IO.d;

            # need some more tests
            my $test-dir = "$dir/test-dir";
            my $test-fil = "$test-dir/test-file";
            my $test-txt = 'test-tex';
            mkdir $test-dir;
            spurt $test-fil, $test-txt;
            unlink $test-fil;
            rmdir $test-dir;
        }
        if $! {
            #note "something failed: '{$!.^name}'";
            next;
        }
        else {
            $todir = $dir;
            last;
        }
    }
    return False if !$todir;

    # create the necessary new dirs
    for @rdirs -> $dir is copy {
        $dir .= subst($workdir, $todir);
        note "DEBUG: \$todir = $dir" if $dbg;
        mkdir $dir if !$dir.IO.d;
    }

    # copy the files
    for @rfils -> $from {
        # copy is from full path to full path
        # so we need some name manipulation
        my $to = $from;
        $to .= subst($workdir, $todir);
        note "DEBUG: \$from = $from" if $dbg;
        note "DEBUG: \$to = $to" if $dbg;
        copy $from, $to;
    }
    return True;
}

