# Copyright (c) 2012 Zmanda, Inc.  All Rights Reserved.
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
#
# Contact information: Zmanda Inc., 465 S. Mathilda Ave., Suite 300
# Sunnyvale, CA 94085, USA, or: http://www.zmanda.com

package Amanda::Rest::Storages;
use strict;
use warnings;

use Amanda::Config qw( :init :getconf config_dir_relative );;
use Amanda::Device qw( :constants );
use Amanda::Changer;
use Amanda::Header;
use Amanda::MainLoop;
use Amanda::Tapelist;
use Amanda::Message;
use Amanda::Recovery;
use Amanda::Recovery::Scan;
use Amanda::Storage;
use Amanda::Rest::Configs;
#use Amanda::Rest::Tapelist;
use Symbol;
use Data::Dumper;
use vars qw(@ISA);

=head1 NAME

Amanda::Rest::Storages -- Rest interface to Amanda::Storage

=head1 INTERFACE

=over

=item Get the list of defined storage

=begin html

<pre>

=end html

request:
  GET /amanda/v1.0/configs/:CONF/storages/:STORAGE

reply:
  HTTP status: 200 OK
  [
     {
        "code" : "1500014",
        "message" : "Defined storage",
        "severity" : "16",
        "source_filename" : "/usr/linux/lib/amanda/perl/Amanda/Rest/Storages.pm",
        "source_line" : "1100",
        "storage" : [
         "my_vtapes",
         "my_robot"
        ]
     }
  ]

=begin html

</pre>

=end html

=item Get parameters values of a storage

=begin html

<pre>

=end html

request:
  GET /amanda/v1.0/configs/:CONF/storages/:STORAGE?fields=runtapes,foo

reply:
  HTTP status: 200 OK
  [
     {
        "code" : "1500011",
        "message" : "Not existant parameters in storage 'my_vtapes'",
        "parameters" : [
           "foo"
        ],
        "severity" : "16",
        "source_filename" : "/usr/lib/amanda/perl/Amanda/Rest/Storages.pm",
        "source_line" : "1063",
        "storage" : "my_vtapes"
     },
     {
        "code" : "1500012",
        "message" : "Parameters values for storage 'my_vtapes'",
        "result" : {
           "runtapes" : 4
        },
        "severity" : "16",
        "source_filename" : "/usr/lib/amanda/perl/Amanda/Rest/Storages.pm",
        "source_line" : "1071",
        "storage" : "my_vtapes"
     }
  ]

=begin html

</pre>

=end html

=item Create a storage

=begin html

<pre>

=end html

request:
  POST /amanda/v1.0/configs/:CONF/storages/:STORAGE/create

reply:
  HTTP status: 200 OK
  [
     {
        "code" : "1100027",
        "dir" : "/amanda/h1/vtapes2",
        "message" : "Created vtape root '/amanda/h1/vtapes2'",
        "severity" : "16",
        "source_filename" : "/usr/lib/amanda/perl/Amanda/Changer/disk.pm",
        "source_line" : "158"
     }
  ]

=begin html

</pre>

=end html

=item Get the inventory of a storage

=begin html

<pre>

=end html

request:
  POST /amanda/v1.0/configs/:CONF/storages/:STORAGE/inventory

reply:
  HTTP status: 200 OK
  [
     {
        "chg_name" : "my_robot",
        "code" : "1100000",
        "message" : "The inventory",
        "severity" : "16",
        "source_filename" : "/usr/lib/amanda/perl/Amanda/Rest/Storages.pm",
        "source_line" : "368",
        "storage_name" : "my_robot",
        "inventory" : [
           {
              "device_error" : null,
              "device_status" : 0,
              "f_type" : 1,
              "label" : "JLM-robot-E01001L4",
              "slot" : "1",
              "state" : 1
           },
           {
              "device_error" : null,
              "device_status" : 0,
              "f_type" : 1,
              "label" : "JLM-robot-E01002L4",
              "slot" : "2",
              "state" : 1
           },
           ...
        ]
     }
  ]

=begin html

</pre>

=end html

=item Load a slot

=begin html

<pre>

=end html

request:
  POST /amanda/v1.0/configs/:CONF/storages/:STORAGE/load?slot=SLOT
  POST /amanda/v1.0/configs/:CONF/storages/:STORAGE/load?label=LABEL

reply:
  HTTP status: 200 OK
  [
     {
        "chg_name" : "my_vtapes",
        "code" : "1100002",
        "load_result" : {
           "datestamp" : "20140120174846",
           "device_status" : 0,
           "f_type" : 1,
           "label" : "test-ORG-AA-vtapes-001"
        },
        "message" : "load result",
        "severity" : "16",
        "source_filename" : "/usr/lib/amanda/perl/Amanda/Rest/Storages.pm",
        "source_line" : "468",
        "storage_name" : "my_vtapes"
     }
  ]
or
  [
     {
        "chg_name" : "my_vtapes",
        "code" : "1100002",
        "load_result" : {
           "device_error" : "File 0 not found",
           "device_status" : 8,
           "device_status_error" : "Volume not labeled"
        },
        "message" : "load result",
        "severity" : "16",
        "source_filename" : "/usr/lib/amanda/perl/Amanda/Rest/Storages.pm",
        "source_line" : "517",
        "storage_name" : "my_vtapes"
     }
  ]

=begin html

</pre>

=end html

=item Reset a storage

=begin html

<pre>

=end html

request:
  POST /amanda/v1.0/configs/:CONF/storages/:STORAGE/reset

reply:
  HTTP status: 200 OK
  [
     {
        "chg_name" : "my_vtapes",
        "code" : "1100003",
        "message" : "Changer is reset",
        "severity" : "16",
        "source_filename" : "/usr/lib/amanda/perl/Amanda/Rest/Storages.pm",
        "source_line" : "588",
        "storage_name" : "my_vtapes"
     }
  ]

=begin html

</pre>

=end html

=item Eject a volume from a drive in a storage

=begin html

<pre>

=end html

request:
  POST /amanda/v1.0/configs/:CONF/storages/:STORAGE/eject?drive=DRIVE

reply:
  HTTP status: 200 OK
  [
     {
        "chg_name" : "my_robot",
        "code" : "1100004",
        "drive" : "1",
        "message" : "Drive '1' ejected",
        "severity" : "16",
        "source_filename" : "/usr/lib/amanda/perl/Amanda/Rest/Storages.pm",
        "source_line" : "705",
        "storage_name" : "my_robot"
     }
  ]
or
  [
     {
        "code" : 3,
        "message" : "drive '0' is empty",
        "reason" : "invalid",
        "severity" : 16,
        "source_filename" : "unknown",
        "source_line" : 0,
        "type" : "failed"
     }
  ]
or
  [
     {
        "code" : 3,
        "message" : "'chg-disk:' does not support eject",
        "reason" : "notimpl",
        "severity" : 16,
        "source_filename" : "unknown",
        "source_line" : 0,
        "type" : "failed"
     }
  ]

=begin html

</pre>

=end html

=item Clean a drive from a storage

=begin html

<pre>

=end html

request:
  POST /amanda/v1.0/configs/:CONF/storages/:STORAGE/clean?drive=DRIVE

reply:
  HTTP status: 200 OK
  [
     {
        "code" : 3,
        "message" : "'chg-robot:' does not support clean",
        "reason" : "notimpl",
        "severity" : 16,
        "source_filename" : "unknown",
        "source_line" : 0,
        "type" : "failed"
     }
  ]

=begin html

</pre>

=end html

=item Verify a storage configuration

=begin html

<pre>

=end html

request:
  POST /amanda/v1.0/configs/:CONF/storages/:STORAGE/verify

reply:
  HTTP status: 200 OK
  [
     {
        "code" : "1100006",
        "device_name" : "tape:/dev/nst0",
        "drive" : "0",
        "message" : "Drive 0 is device tape:/dev/nst0",
        "severity" : "16",
        "source_filename" : "/usr/lib/amanda/perl/Amanda/Changer/robot.pm",
        "source_line" : "1731"
     },
     {
        "code" : "1100006",
        "device_name" : "tape:/dev/nst1",
        "drive" : "1",
        "message" : "Drive 1 is device tape:/dev/nst1",
        "severity" : "16",
        "source_filename" : "/usr/lib/amanda/perl/Amanda/Changer/robot.pm",
        "source_line" : "1731"
     },
     {
        "code" : "1100025",
        "device_name" : "tape:/dev/nst12",
        "drive" : "3",
        "error" : "Can't open tape device /dev/nst12: No such file or directory",
        "message" : "Drive 3: device 'tape:/dev/nst12' error: Can't open tape device /dev/nst12: No such file or directory",
        "severity" : "16",
        "source_filename" : "/usr/lib/amanda/perl/Amanda/Changer/robot.pm",
        "source_line" : "1722"
     },
     {
        "code" : "1100009",
        "device_name" : "tape:/dev/nst3",
        "drive" : "2",
        "message" : "Drive 2 is not device tape:/dev/nst3",
        "severity" : "16",
        "source_filename" : "/usr/lib/amanda/perl/Amanda/Changer/robot.pm",
        "source_line" : "1714"
     },
     {
        "code" : "1100007",
        "device_name" : "tape:/dev/nst2",
        "drive" : "2",
        "message" : "Drive 2 looks to be device tape:/dev/nst2",
        "severity" : "16",
        "source_filename" : "/usr/lib/amanda/perl/Amanda/Changer/robot.pm",
        "source_line" : "1741"
     },
     {
        "code" : "1100008",
        "message" : "property \"TAPE-DEVICE\" \"0=tape:/dev/nst0\" \"1=tape:/dev/nst1\" \"2=tape:/dev/nst2\" \"3=tape:/dev/nst3\"",
        "severity" : "16",
        "source_filename" : "/usr/lib/amanda/perl/Amanda/Changer/robot.pm",
        "source_line" : "1778",
        "tape_devices" : " \"0=tape:/dev/nst0\" \"1=tape:/dev/nst1\" \"2=tape:/dev/nst2\" \"3=tape:/dev/nst3\""
     }
  ]

=begin html

</pre>

=end html

=item Show what is in the storage (scan the storage)

=begin html

<pre>

=end html

request:
  POST /amanda/v1.0/configs/:CONF/storages/:STORAGE/show
  POST /amanda/v1.0/configs/:CONF/storages/:STORAGE/show?slots=3..5

reply:
  HTTP status: 200 OK
  [
     {
        "code" : "1100010",
        "message" : "scanning all 20 slots in changer:",
        "num_slots" : "20",
        "severity" : "16",
        "source_filename" : "/usr/lib/amanda/perl/Amanda/Changer.pm",
        "source_line" : "1634"
     },
     {
        "code" : "1100015",
        "datestamp" : "20140120174913",
        "label" : "test-ORG-AA-vtapes-003",
        "message" : "slot   3: date 20140120174913 label test-ORG-AA-vtapes-003",
        "severity" : "16",
        "slot" : "3",
        "source_filename" : "/usr/lib/amanda/perl/Amanda/Changer.pm",
        "source_line" : "1708",
        "write_protected" : ""
     },
     {
        "code" : "1100015",
        "datestamp" : "20140120191101",
        "label" : "test-ORG-AA-vtapes-004",
        "message" : "slot   4: date 20140120191101 label test-ORG-AA-vtapes-004",
        "severity" : "16",
        "slot" : "4",
        "source_filename" : "/usr/lib/amanda/perl/Amanda/Changer.pm",
        "source_line" : "1708",
        "write_protected" : ""
     },
     {
        "code" : "1100015",
        "datestamp" : "20140120191153",
        "label" : "test-ORG-AA-vtapes-005",
        "message" : "slot   5: date 20140120191153 label test-ORG-AA-vtapes-005",
        "severity" : "16",
        "slot" : "5",
        "source_filename" : "/usr/lib/amanda/perl/Amanda/Changer.pm",
        "source_line" : "1708",
        "write_protected" : ""
     }
  ]

=begin html

</pre>

=end html

=item Update the storage (amtape update)

=begin html

<pre>

=end html

request:
  POST /amanda/v1.0/configs/:CONF/storages/:STORAGE/update
  POST /amanda/v1.0/configs/:CONF/storages/:STORAGE/update?changed=CHANGED

reply:
  HTTP status: 200 OK
  [
     {
        "code" : "1100019",
        "message" : "scanning slot 1",
        "severity" : "16",
        "slot" : "1",
        "source_filename" : "/usr/lib/amanda/perl/Amanda/Changer/robot.pm",
        "source_line" : "1346"
     },
     ...
     {
        "chg_name" : "my_robot",
        "code" : "1100018",
        "message" : "Update completed",
        "severity" : "16",
        "source_filename" : "/usr/lib/amanda/perl/Amanda/Rest/Storages.pm",
        "source_line" : "1084",
        "storage_name" : "my_robot"
     }
  ]

=begin html

</pre>

=end html

=back

=cut

sub inventory {
    my %params = @_;
    my @result_messages = Amanda::Rest::Configs::config_init(@_);
    return \@result_messages if @result_messages;

    my $tlf = Amanda::Config::config_dir_relative(getconf($CNF_TAPELIST));
    (my $tl, my $message) = Amanda::Tapelist->new($tlf);
    if (defined $message) {
	push @result_messages, $message;
	return \@result_messages;
    }

    my $user_msg = sub {
        my $msg = shift;
        push @result_messages, $msg;
    };

    my $main = sub {
	my $finished_cb = shift;
	my $storage;
	my $chg;

	my $steps = define_steps
	    cb_ref => \$finished_cb,
	    finalize => sub { $storage->quit() if defined $storage;
			      $chg->quit() if defined $chg };

	step start => sub {
	    $storage = Amanda::Storage->new(storage_name => $params{'STORAGE'},
				tapelist => $tl);
	    if ($storage->isa("Amanda::Changer::Error")) {
		Dancer::status(404);
		push @result_messages, $storage;
		return $steps->{'done'}->();
	    }

	    $chg = $storage->{'chg'};
	    if ($chg->isa("Amanda::Changer::Error")) {
		Dancer::status(404);
		push @result_messages, $chg;
		return $steps->{'done'}->();
	    }

	    return $chg->inventory(inventory_cb => $steps->{'inventory_cb'});
	};

	step inventory_cb => sub {
	    my ($err, $inventory) = @_;

	    push @result_messages, $err if $err;

	    push @result_messages, Amanda::Changer::Message->new(
				source_filename => __FILE__,
				source_line     => __LINE__,
				code            => 1100000,
				storage_name    => $storage->{'storage_name'},
				chg_name        => $chg->{'chg_name'},
				inventory => $inventory) if $inventory;

	    return $steps->{'done'}->();
	};

	step done => sub {
	    my $err = shift;
	    push @result_messages, $err if $err;
	    return $finished_cb->();
	};
    };

    $main->(\&Amanda::MainLoop::quit);
    Amanda::MainLoop::run();
    $main = undef;

    return \@result_messages;
}

sub load {
    my %params = @_;
    my @result_messages = Amanda::Rest::Configs::config_init(@_);
    return \@result_messages if @result_messages;

    my $tlf = Amanda::Config::config_dir_relative(getconf($CNF_TAPELIST));
    (my $tl, my $message) = Amanda::Tapelist->new($tlf);
    if (defined $message) {
	push @result_messages, $message;
	return \@result_messages;
    }

    my $user_msg = sub {
        my $msg = shift;
        push @result_messages, $msg;
    };

    my $main = sub {
	my $finished_cb = shift;
	my $storage;
	my $chg;

	my $steps = define_steps
	    cb_ref => \$finished_cb,
	    finalize => sub { $storage->quit() if defined $storage;
			      $chg->quit() if defined $chg };

	step start => sub {
	    $storage = Amanda::Storage->new(storage_name => $params{'STORAGE'},
				tapelist => $tl);
	    if ($storage->isa("Amanda::Changer::Error")) {
		Dancer::status(404);
		push @result_messages, $storage;
		return $steps->{'done'}->();
	    }

	    $chg = $storage->{'chg'};
	    if ($chg->isa("Amanda::Changer::Error")) {
		push @result_messages, $chg;
		return $steps->{'done'}->();
	    }

	    my %args;
	    $args{'label'} = $params{'label'} if defined $params{'label'};
	    $args{'slot'} = $params{'slot'} if defined $params{'slot'};
	    $args{'relative_slot'} = $params{'relative_slot'} if defined $params{'relative_slot'};
	    $args{'res_cb'} = $steps->{'res_cb'};
	    return $chg->load(%args);
	};

	step res_cb => sub {
	    my ($err, $res) = @_;

	    if ($err) {
		push @result_messages, $err;
		return $steps->{'done'}->();
	    }

	    my $dev = $res->{'device'};
	    if (!defined $dev) {
		push @result_messages, Amanda::Changer::Message->new(
					source_filename => __FILE__,
					source_line => __LINE__,
					code   => 1100001);
		return $steps->{'done'}->();
	    }

	    my $ret;
	    $ret->{'device_status'} = $dev->status;
	    if ($dev->status != $DEVICE_STATUS_SUCCESS) {
		$ret->{'device_status_error'} = $dev->status_error;
		$ret->{'device_error'} = $dev->error;
	    } else {
		my $volume_header = $dev->volume_header;
		$ret->{'f_type'} = $volume_header->{'type'};
		if ($ret->{'f_type'} == $Amanda::Header::F_TAPESTART) {
		    $ret->{'datestamp'} = $volume_header->{'datestamp'};
		    $ret->{'label'} = $volume_header->{'name'};
		}
	    }
	    push @result_messages, Amanda::Changer::Message->new(
					source_filename => __FILE__,
					source_line => __LINE__,
					storage_name    => $storage->{'storage_name'},
					chg_name        => $chg->{'chg_name'},
					code   => 1100002,
					load_result => $ret);

	    return $res->release(finished_cb => $steps->{'done'});
	};

	step done => sub {
	    my $err = shift;
	    push @result_messages, $err if $err;
	    return $finished_cb->();
	};

    };

    $main->(\&Amanda::MainLoop::quit);
    Amanda::MainLoop::run();
    $main = undef;

    return \@result_messages;
}

sub reset {
    my %params = @_;
    my @result_messages = Amanda::Rest::Configs::config_init(@_);
    return \@result_messages if @result_messages;

    my $tlf = Amanda::Config::config_dir_relative(getconf($CNF_TAPELIST));
    (my $tl, my $message) = Amanda::Tapelist->new($tlf);
    if (defined $message) {
	push @result_messages, $message;
	return \@result_messages;
    }

    my $user_msg = sub {
        my $msg = shift;
        push @result_messages, $msg;
    };

    my $main = sub {
	my $finished_cb = shift;
	my $storage;
	my $chg;

	my $steps = define_steps
	    cb_ref => \$finished_cb,
	    finalize => sub { $storage->quit() if defined $storage;
			      $chg->quit() if defined $chg };

	step start => sub {
	    $storage = Amanda::Storage->new(storage_name => $params{'STORAGE'},
				tapelist => $tl);
	    if ($storage->isa("Amanda::Changer::Error")) {
		Dancer::status(404);
		push @result_messages, $storage;
		return $steps->{'done'}->();
	    }

	    $chg = $storage->{'chg'};
	    if ($chg->isa("Amanda::Changer::Error")) {
		Dancer::status(404);
		push @result_messages, $chg;
		return $steps->{'done'}->();
	    }

	    return $chg->reset(finished_cb => $steps->{'reset_cb'});
	};

	step reset_cb => sub {
	    my ($err, $res) = @_;

	    if ($err) {
		Dancer::status(405);
		push @result_messages, $chg;
	    } else {
		push @result_messages, Amanda::Changer::Message->new(
					source_filename => __FILE__,
					source_line => __LINE__,
					storage_name    => $storage->{'storage_name'},
					chg_name        => $chg->{'chg_name'},
					code   => 1100003);
	    }
	    return $steps->{'done'}->();
	};

	step done => sub {
	    my $err = shift;
	    push @result_messages, $err if $err;
	    return $finished_cb->();
	};

    };

    $main->(\&Amanda::MainLoop::quit);
    Amanda::MainLoop::run();
    $main = undef;

    return \@result_messages;
}

sub eject {
    my %params = @_;
    my @result_messages = Amanda::Rest::Configs::config_init(@_);
    return \@result_messages if @result_messages;

    my $tlf = Amanda::Config::config_dir_relative(getconf($CNF_TAPELIST));
    (my $tl, my $message) = Amanda::Tapelist->new($tlf);
    if (defined $message) {
	push @result_messages, $message;
	return \@result_messages;
    }

    my $user_msg = sub {
        my $msg = shift;
        push @result_messages, $msg;
    };

    my $main = sub {
	my $finished_cb = shift;
	my $storage;
	my $chg;

	my $steps = define_steps
	    cb_ref => \$finished_cb,
	    finalize => sub { $storage->quit() if defined $storage;
			      $chg->quit() if defined $chg };

	step start => sub {
	    $storage = Amanda::Storage->new(storage_name => $params{'STORAGE'},
				tapelist => $tl);
	    if ($storage->isa("Amanda::Changer::Error")) {
		Dancer::status(404);
		push @result_messages, $storage;
		return $steps->{'done'}->();
	    }

	    $chg = $storage->{'chg'};
	    if ($chg->isa("Amanda::Changer::Error")) {
		Dancer::status(404);
		push @result_messages, $chg;
		return $steps->{'done'}->();
	    }

	    return $chg->eject(drive => $params{'drive'},
			       finished_cb => $steps->{'eject_cb'});
	};

	step eject_cb => sub {
	    my ($err) = @_;

	    if ($err) {
		Dancer::status(405);
		push @result_messages, $err;
	    } else {
		push @result_messages, Amanda::Changer::Message->new(
					source_filename => __FILE__,
					source_line => __LINE__,
					storage_name    => $storage->{'storage_name'},
					chg_name        => $chg->{'chg_name'},
					code   => 1100004,
					drive  => $params{'drive'});
	    }
	    return $steps->{'done'}->();
	};

	step done => sub {
	    my $err = shift;
	    push @result_messages, $err if $err;
	    return $finished_cb->();
	};

    };

    $main->(\&Amanda::MainLoop::quit);
    Amanda::MainLoop::run();
    $main = undef;

    return \@result_messages;
}

sub clean {
    my %params = @_;
    my @result_messages = Amanda::Rest::Configs::config_init(@_);
    return \@result_messages if @result_messages;

    my $tlf = Amanda::Config::config_dir_relative(getconf($CNF_TAPELIST));
    (my $tl, my $message) = Amanda::Tapelist->new($tlf);
    if (defined $message) {
	push @result_messages, $message;
	return \@result_messages;
    }

    my $user_msg = sub {
        my $msg = shift;
        push @result_messages, $msg;
    };

    my $main = sub {
	my $finished_cb = shift;
	my $storage;
	my $chg;

	my $steps = define_steps
	    cb_ref => \$finished_cb,
	    finalize => sub { $storage->quit() if defined $storage;
			      $chg->quit() if defined $chg };

	step start => sub {
	    $storage = Amanda::Storage->new(storage_name => $params{'STORAGE'},
				tapelist => $tl);
	    if ($storage->isa("Amanda::Changer::Error")) {
		push @result_messages, $storage;
		return $steps->{'done'}->();
	    }

	    $chg = $storage->{'chg'};
	    if ($chg->isa("Amanda::Changer::Error")) {
		push @result_messages, $chg;
		return $steps->{'done'}->();
	    }

	    return $chg->clean(drive => $params{'drive'},
			       finished_cb => $steps->{'clean_cb'});
	};

	step clean_cb => sub {
	    my ($err) = @_;

	    if ($err) {
		Dancer::status(405);
		push @result_messages, $err;
	    } else {
		push @result_messages, Amanda::Changer::Message->new(
					source_filename => __FILE__,
					source_line => __LINE__,
					code   => 1100005,
					storage_name    => $storage->{'storage_name'},
					chg_name        => $chg->{'chg_name'},
					drive  => $params{'drive'});
	    }
	    return $steps->{'done'}->();
	};

	step done => sub {
	    my $err = shift;
	    push @result_messages, $err if $err;
	    $finished_cb->();
	};

    };

    $main->(\&Amanda::MainLoop::quit);
    Amanda::MainLoop::run();
    $main = undef;

    return \@result_messages;
}

sub create {
    my %params = @_;
    my @result_messages = Amanda::Rest::Configs::config_init(@_);
    return \@result_messages if @result_messages;

    my $tlf = Amanda::Config::config_dir_relative(getconf($CNF_TAPELIST));
    (my $tl, my $message) = Amanda::Tapelist->new($tlf);
    if (defined $message) {
	push @result_messages, $message;
	return \@result_messages;
    }

    my $user_msg = sub {
        my $msg = shift;
        push @result_messages, $msg;
    };

    my $main = sub {
	my $finished_cb = shift;
	my $storage;
	my $chg;

	my $steps = define_steps
	    cb_ref => \$finished_cb,
	    finalize => sub { $storage->quit() if defined $storage;
			      $chg->quit() if defined $chg };

	step start => sub {
	    $storage = Amanda::Storage->new(storage_name => $params{'STORAGE'},
				tapelist => $tl,
					    no_validate  => 1);
	    if ($storage->isa("Amanda::Changer::Error")) {
		Dancer::status(404);
		push @result_messages, $storage;
		return $steps->{'done'}->();
	    }

	    $chg = $storage->{'chg'};
	    if ($chg->isa("Amanda::Changer::Error")) {
		Dancer::status(404);
		push @result_messages, $chg;
		return $steps->{'done'}->();
	    }

	    return $chg->create(finished_cb => $steps->{'create_cb'});
	};

	step create_cb => sub {
	    my ($err, @results) = @_;

	    if ($err) {
		push @result_messages, $err;
	    } else {
		push @result_messages, @results;
	    }
	    return $steps->{'done'}->();
	};

	step done => sub {
	    my $err = shift;
	    push @result_messages, $err if $err;
	    return $finished_cb->();
	};

    };

    $main->(\&Amanda::MainLoop::quit);
    Amanda::MainLoop::run();
    $main = undef;

    return \@result_messages;
}

sub verify {
    my %params = @_;
    my @result_messages = Amanda::Rest::Configs::config_init(@_);
    return \@result_messages if @result_messages;

    my $tlf = Amanda::Config::config_dir_relative(getconf($CNF_TAPELIST));
    (my $tl, my $message) = Amanda::Tapelist->new($tlf);
    if (defined $message) {
	push @result_messages, $message;
	return \@result_messages;
    }

    my $user_msg = sub {
        my $msg = shift;
        push @result_messages, $msg;
    };

    my $main = sub {
	my $finished_cb = shift;
	my $storage;
	my $chg;

	my $steps = define_steps
	    cb_ref => \$finished_cb,
	    finalize => sub { $storage->quit() if defined $storage;
			      $chg->quit() if defined $chg };

	step start => sub {
	    $storage = Amanda::Storage->new(storage_name => $params{'STORAGE'},
				tapelist => $tl);
	    if ($storage->isa("Amanda::Changer::Error")) {
		Dancer::status(404);
		push @result_messages, $storage;
		return $steps->{'done'}->();
	    }

	    $chg = $storage->{'chg'};
	    if ($chg->isa("Amanda::Changer::Error")) {
		Dancer::status(404);
		push @result_messages, $chg;
		return $steps->{'done'}->();
	    }

	    return $chg->verify(finished_cb => $steps->{'verify_cb'});
	};

	step verify_cb => sub {
	    my ($err, @results) = @_;

	    if ($err) {
		Dancer::status(405);
		push @result_messages, $err;
	    } else {
		push @result_messages, @results;
	    }
	    return $steps->{'done'}->();
	};

	step done => sub {
	    my $err = shift;
	    push @result_messages, $err if $err;
	    return $finished_cb->();
	};

    };

    $main->(\&Amanda::MainLoop::quit);
    Amanda::MainLoop::run();
    $main = undef;

    return \@result_messages;
}

sub show {
    my %params = @_;
    my @result_messages = Amanda::Rest::Configs::config_init(@_);
    return \@result_messages if @result_messages;

    my $tlf = Amanda::Config::config_dir_relative(getconf($CNF_TAPELIST));
    (my $tl, my $message) = Amanda::Tapelist->new($tlf);
    if (defined $message) {
	push @result_messages, $message;
	return \@result_messages;
    }

    my $user_msg = sub {
        my $msg = shift;
        push @result_messages, $msg;
    };

    my $main = sub {
	my $finished_cb = shift;
	my $storage;
	my $chg;

	my $steps = define_steps
	    cb_ref => \$finished_cb,
	    finalize => sub { $storage->quit() if defined $storage;
			      $chg->quit() if defined $chg };

	step start => sub {
	    $storage = Amanda::Storage->new(storage_name => $params{'STORAGE'},
				tapelist => $tl);
	    if ($storage->isa("Amanda::Changer::Error")) {
		Dancer::status(404);
		push @result_messages, $storage;
		return $steps->{'done'}->();
	    }

	    $chg = $storage->{'chg'};
	    if ($chg->isa("Amanda::Changer::Error")) {
		Dancer::status(404);
		push @result_messages, $chg;
		return $steps->{'done'}->();
	    }

	    $chg->show(slots => $params{'slots'},
		       user_msg => $user_msg,
		       finished_cb => $steps->{'done'});
	};

	step done => sub {
	    my $err = shift;
	    push @result_messages, $err if $err;
	    return $finished_cb->();
	};

    };

    $main->(\&Amanda::MainLoop::quit);
    Amanda::MainLoop::run();
    $main = undef;

    return \@result_messages;
}

sub label {
    my %params = @_;
    my @result_messages = Amanda::Rest::Configs::config_init(@_);
    return \@result_messages if @result_messages;

    if (!defined $params{'label'}) {
	push @result_messages, Amanda::Config::Message->new(
				source_filename => __FILE__,
				source_line     => __LINE__,
				code   => 1500015);
	return \@result_messages;
    }

    my $tlf = Amanda::Config::config_dir_relative(getconf($CNF_TAPELIST));
    (my $tl, my $message) = Amanda::Tapelist->new($tlf);
    if (defined $message) {
	push @result_messages, $message;
	return \@result_messages;
    }

    my $user_msg = sub {
        my $msg = shift;
        push @result_messages, $msg;
    };

    my $main = sub {
	my $finished_cb = shift;
	my $storage;
	my $chg;
	my $scan;

	my $steps = define_steps
	    cb_ref => \$finished_cb,
	    finalize => sub { $scan->quit() if defined $scan;
			      $storage->quit() if defined $storage;
			      $chg->quit() if defined $chg };

	step start => sub {
	    $storage = Amanda::Storage->new(storage_name => $params{'STORAGE'},
				tapelist => $tl);
	    if ($storage->isa("Amanda::Changer::Error")) {
		return $steps->{'done'}->($storage);
	    }

	    $chg = $storage->{'chg'};
	    if ($chg->isa("Amanda::Changer::Error")) {
		return $steps->{'done'}->($chg);
	    }

	    $scan = Amanda::Recovery::Scan->new(chg => $chg);
	    if ($scan->isa("Amanda::Changer::Error")) {
		push @result_messages, $scan;
		return $steps->{'done'}->();
	    }
	    $scan->find_volume(label => $params{'label'},
			       res_cb => $steps->{'done_load'},
			       user_msg => $user_msg);
	};

	step done_load => sub {
	    my ($err, $res) = @_;

	    return $steps->{'done'}->($err) if $err;

	    my $gotslot = $res->{'this_slot'};
	    my $devname = $res->{'device'}->device_name;

	    push @result_messages, Amanda::Recovery::Message->new(
				source_filename => __FILE__,
				source_line     => __LINE__,
				storage_name    => $storage->{'storage_name'},
				chg_name        => $chg->{'chg_name'},
				code   => 1200004,
				slot   => $res->{'this_slot'},
				label  => $params{'label'},
				device => $res->{'device'}->device_name);
	    $res->release(finished_cb => $steps->{'done'});
	};

	step done => sub {
	    my $err = shift;
	    push @result_messages, $err if $err;
	    return $finished_cb->();
	};

    };

    $main->(\&Amanda::MainLoop::quit);
    Amanda::MainLoop::run();
    $main = undef;

    return \@result_messages;
}

sub update {
    my %params = @_;
    my @result_messages = Amanda::Rest::Configs::config_init(@_);
    return \@result_messages if @result_messages;

    my $user_msg = sub {
        my $msg = shift;
        push @result_messages, $msg;
    };

    my $tlf = Amanda::Config::config_dir_relative(getconf($CNF_TAPELIST));
    (my $tl, my $message) = Amanda::Tapelist->new($tlf);
    if (defined $message) {
	push @result_messages, $message;
	return \@result_messages;
    }

    my $main = sub {
	my $finished_cb = shift;
	my $storage;
	my $chg;

	my $steps = define_steps
	    cb_ref => \$finished_cb,
	    finalize => sub { $storage->quit() if defined $storage;
			      $chg->quit() if defined $chg };

	step start => sub {
	    $storage = Amanda::Storage->new(storage_name => $params{'STORAGE'},
				tapelist => $tl);
	    if ($storage->isa("Amanda::Changer::Error")) {
		Dancer::status(404);
		return $steps->{'done'}->($storage);
	    }

	    $chg = $storage->{'chg'};
	    if ($chg->isa("Amanda::Changer::Error")) {
		Dancer::status(404);
		return $steps->{'done'}->($chg);
	    }

	    return $chg->update(user_msg_fn => $user_msg,
				finished_cb => $steps->{'done'},
				changed     => $params{'changed'});
	};

	step done => sub {
	    my $err = shift;
	    if ($err) {
		Dancer::status(405);;
		push @result_messages, $err;
	    } else {
		push @result_messages, Amanda::Changer::Message->new(
				source_filename => __FILE__,
				source_line     => __LINE__,
				storage_name    => $storage->{'storage_name'},
				chg_name        => $chg->{'chg_name'},
				code   => 1100018);
	    }
	    return $finished_cb->();
	};

    };

    $main->(\&Amanda::MainLoop::quit);
    Amanda::MainLoop::run();
    $main = undef;

    return \@result_messages;
}

sub fields {
    my %params = @_;

    my @result_messages = Amanda::Rest::Configs::config_init(@_);
    return \@result_messages if @result_messages;

    my $storage_name = $params{'STORAGE'};
    my $st = Amanda::Config::lookup_storage($storage_name);
    if (!$st) {
        push @result_messages, Amanda::Config::Message->new(
				source_filename => __FILE__,
				source_line     => __LINE__,
				code      => 1500010,
				storage   => $storage_name);
	return \@result_messages;
    }

    my @no_parameters;
    my %values;
    foreach my $name (split ',', $params{'fields'}) {
        my $result = Amanda::Config::getconf_byname("storage:$storage_name:$name");
        if (!defined $result) {
            push @no_parameters, $name;
        } else {
            $values{$name} = $result;
        }
    }
    if (@no_parameters) {
        push @result_messages, Amanda::Config::Message->new(
				source_filename => __FILE__,
				source_line     => __LINE__,
				code       => 1500011,
				storage    => $storage_name,
				parameters => \@no_parameters);
    }
    if (%values) {
        push @result_messages, Amanda::Config::Message->new(
				source_filename => __FILE__,
				source_line     => __LINE__,
				code      => 1500012,
				storage    => $storage_name,
				result    => \%values);
    }
    if (!@no_parameters and !%values) {
        push @result_messages, Amanda::Config::Message->new(
				source_filename => __FILE__,
				source_line     => __LINE__,
				storage   => $storage_name,
				code      => 1500009);
    }
    return \@result_messages;
}

sub list {
    my %params = @_;

    my @result_messages = Amanda::Rest::Configs::config_init(@_);
    return \@result_messages if @result_messages;

    my @storage = Amanda::Config::get_storage_list();
    if (!@storage) {
        push @result_messages, Amanda::Config::Message->new(
				source_filename => __FILE__,
				source_line     => __LINE__,
				code       => 1500013);
    } else {
        push @result_messages, Amanda::Config::Message->new(
				source_filename => __FILE__,
				source_line     => __LINE__,
				code       => 1500014,
				storage    => \@storage);
    }

    return \@result_messages;
}

1;
