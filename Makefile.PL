#!/usr/bin/perl

use inc::Module::Install;

name		('VCP-Source-cvsbk');
author		('Chia-liang Kao <clkao@clkao.org>');
abstract	('VCP source driver for bk exported cvs');
license		('perl');
version_from	('lib/VCP/Source/cvsbk.pm');

requires(
        'VCP'   => '0.9',
);
include('ExtUtils::AutoInstall');
auto_install();

WriteAll( sign => 1 );
