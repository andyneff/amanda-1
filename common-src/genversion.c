/*
 * Amanda, The Advanced Maryland Automatic Network Disk Archiver
 * Copyright (c) 1991-1999 University of Maryland at College Park
 * All Rights Reserved.
 *
 * Permission to use, copy, modify, distribute, and sell this software and its
 * documentation for any purpose is hereby granted without fee, provided that
 * the above copyright notice appear in all copies and that both that
 * copyright notice and this permission notice appear in supporting
 * documentation, and that the name of U.M. not be used in advertising or
 * publicity pertaining to distribution of the software without specific,
 * written prior permission.  U.M. makes no representations about the
 * suitability of this software for any purpose.  It is provided "as is"
 * without express or implied warranty.
 *
 * U.M. DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE, INCLUDING ALL
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS, IN NO EVENT SHALL U.M.
 * BE LIABLE FOR ANY SPECIAL, INDIRECT OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION
 * OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN
 * CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *
 * Authors: the Amanda Development Team.  Its members are listed in a
 * file named AUTHORS, in the root directory of this distribution.
 */
/*
 * $Id$
 *
 * dump the current Amanda version info
 */
#include "amanda.h"
#include "version.h"

/* distribution-time information */
#include "svn-info.h"

/* build-time information */
#include "genversion.h"

#define	LMARGIN		6
#define RMARGIN 	70

static size_t linelen;

#define	startline(title)  g_printf("  \"%-*s", LMARGIN, title); linelen = 0
#define	endline()	  g_printf("\\n\",\n")

static void prstr(const char *);
static void prvar(const char *, const char *);
static void prundefvar(const char *var);
static void prnum(const char *var, long val);

int main(int, char **);

/* Print a string */
static void
prstr(
    const char *string)
{
    size_t len = strlen(string) + 1;

    /*
     * If this string overflows this line, and there's other stuff
     * on the line, create a new one.
     */
    if (linelen > 0 && linelen + len >= RMARGIN - LMARGIN) {
	endline();
	startline("");
    }
    g_printf(" %s", string);
    linelen += len;
}

static char *buf = NULL;
static size_t buf_len = 0;

/* Print a text variable */
static void
prvar(
    const char *var,
    const char *val)
{
    size_t new_len;

    new_len = strlen(var)
	      + SIZEOF("=\\\"")
	      + strlen(val)
	      + SIZEOF("\\\"")
	      + 1;
    if(new_len > buf_len) {
	free(buf);
	buf_len = new_len;
	buf = malloc(new_len);
	if (!buf) {
	    g_fprintf(stderr, _("genversion: Not enough memory"));
	    abort();
	    /*NOTREACHED*/
	}
    }
    g_snprintf(buf, buf_len, "%s=\\\"%s\\\"", var, val);	/* safe */
    prstr(buf);
}

/* Print a undef variable */
static void
prundefvar(
    const char *var)
{
    size_t new_len;

    new_len = strlen(var)
	      + SIZEOF("=UNDEF")
	      + 1;
    if(new_len > buf_len) {
	free(buf);
	buf_len = new_len;
	buf = malloc(new_len);		/* let it die if malloc() fails */
	if (!buf) {
	    g_fprintf(stderr, _("genversion: Not enough memory"));
	    abort();
	    /*NOTREACHED*/
	}
    }
    g_snprintf(buf, buf_len, "%s=UNDEF", var);	/* safe */
    prstr(buf);
}

/* Print a numeric variable */
static void
prnum(
    const char *var,
    long	val)
{
    static char number[NUM_STR_SIZE];
    size_t new_len;

    g_snprintf(number, SIZEOF(number), "%ld", val);
    new_len = strlen(var)
	      + SIZEOF("=")
	      + strlen(number)
	      + 1;
    if(new_len > buf_len) {
	free(buf);
	buf_len = new_len;
	buf = malloc(new_len);		/* let it die if malloc() fails */
	if (!buf) {
	    g_fprintf(stderr, _("genversion: Not enough memory"));
	    abort();
	    /*NOTREACHED*/
	}
    }
    g_snprintf(buf, buf_len, "%s=%s", var, number);		/* safe */
    prstr(buf);
}

int
main(
    int		argc,
    char **	argv)
{
    const char *v;
    char *verstr;
    size_t v_len;

    (void)argc;	/* Quiet unused parameter warning */
    (void)argv;	/* Quiet unused parameter warning */

    /*
     * Configure program for internationalization:
     *   1) Only set the message locale for now.
     *   2) Set textdomain for all amanda related programs to "amanda"
     *      We don't want to be forced to support dozens of message catalogs.
     */  
    setlocale(LC_MESSAGES, "C");
    textdomain("amanda"); 

    g_printf(_("/* version.c - generated by genversion.c - DO NOT EDIT! */\n"));
    g_printf("const char * const version_info[] = {\n");

    startline("build:");
    v = version();
    v_len = SIZEOF("Amanda-") + strlen(v) + 1;
    verstr = malloc(v_len);
    if (!verstr) {
	g_fprintf(stderr, _("genversion: Not enough memory"));
	abort();
	/*NOTREACHED*/
    }
    g_snprintf(verstr, v_len, "Amanda-%s", v);		/* safe */
    prvar("VERSION", verstr);
    free(verstr);

#ifdef BUILT_DATE
    prvar("BUILT_DATE", BUILT_DATE);
#else
    prundefvar("BUILT_DATE");
#endif

#ifdef BUILT_MACH
    prvar("BUILT_MACH", BUILT_MACH);
#else
    prundefvar("BUILT_MACH");
#endif

#ifdef BUILT_REV
    prvar("BUILT_REV", BUILT_REV);
#else
    prundefvar("BUILT_REV");
#endif

#ifdef BUILT_BRANCH
    prvar("BUILT_BRANCH", BUILT_BRANCH);
#else
    prundefvar("BUILT_BRANCH");
#endif

#ifdef CC
    prvar("CC", CC);
#else
    prundefvar("CC");
#endif

    endline();

    startline("paths:");

    prvar("bindir", bindir);
    prvar("sbindir", sbindir);
    prvar("libexecdir", libexecdir);
    prvar("mandir", mandir);
    prvar("AMANDA_TMPDIR", AMANDA_TMPDIR);
#ifdef AMANDA_DBGDIR
    prvar("AMANDA_DBGDIR", AMANDA_DBGDIR);
#else
    prundefvar("AMANDA_DBGDIR");
#endif
    prvar("CONFIG_DIR", CONFIG_DIR);

#ifdef DEV_PREFIX
    prvar("DEV_PREFIX", DEV_PREFIX);
#else
    prundefvar("DEV_PREFIX");
#endif

#ifdef RDEV_PREFIX
    prvar("RDEV_PREFIX", RDEV_PREFIX);
#else
    prundefvar("RDEV_PREFIX");
#endif

#ifdef DUMP
    prvar("DUMP", DUMP);
    prvar("RESTORE", RESTORE);
#else
    prundefvar("DUMP");
    prundefvar("RESTORE");
#endif

#ifdef VDUMP
    prvar("VDUMP", VDUMP);
    prvar("VRESTORE", VRESTORE);
#else
    prundefvar("VDUMP");
    prundefvar("VRESTORE");
#endif

#ifdef XFSDUMP
    prvar("XFSDUMP", XFSDUMP);
    prvar("XFSRESTORE", XFSRESTORE);
#else
    prundefvar("XFSDUMP");
    prundefvar("XFSRESTORE");
#endif

#ifdef VXDUMP
    prvar("VXDUMP", VXDUMP);
    prvar("VXRESTORE", VXRESTORE);
#else
    prundefvar("VXDUMP");
    prundefvar("VXRESTORE");
#endif

#ifdef SAMBA_CLIENT
    prvar("SAMBA_CLIENT", SAMBA_CLIENT);
#else
    prundefvar("SAMBA_CLIENT");
#endif

#ifdef GNUTAR
    prvar("GNUTAR", GNUTAR);
#else
    prundefvar("GNUTAR");
#endif

#ifdef COMPRESS_PATH
    prvar("COMPRESS_PATH", COMPRESS_PATH);
#else
    prundefvar("COMPRESS_PATH");
#endif

#ifdef UNCOMPRESS_PATH
    prvar("UNCOMPRESS_PATH", UNCOMPRESS_PATH);
#else
    prundefvar("UNCOMPRESS_PATH");
#endif

#ifdef LPRCMD
    prvar("LPRCMD", LPRCMD);
#else
    prundefvar(" LPRCMD");
#endif

#ifdef MAILER
    prvar("MAILER", MAILER);
#else
    prundefvar(" MAILER");
#endif

#ifdef GNUTAR_LISTED_INCREMENTAL_DIR
    prvar("listed_incr_dir", GNUTAR_LISTED_INCREMENTAL_DIR);
#else
    prundefvar("GNUTAR_LISTED_INCREMENTAL_DIR");
#endif
    endline();

    startline("defs:");

    prvar("DEFAULT_SERVER", DEFAULT_SERVER);
    prvar("DEFAULT_CONFIG", DEFAULT_CONFIG);
    prvar("DEFAULT_TAPE_SERVER", DEFAULT_TAPE_SERVER);

#ifdef DEFAULT_TAPE_DEVICE
    prvar("DEFAULT_TAPE_DEVICE", DEFAULT_TAPE_DEVICE);
#endif

#ifdef AIX_BACKUP
    prstr("AIX_BACKUP");
#endif

#ifdef BROKEN_VOID
    prstr("BROKEN_VOID");
#endif

#ifdef DUMP_RETURNS_1
    prstr("DUMP_RETURNS_1");
#endif

#ifdef HAVE_MMAP
    prstr("HAVE_MMAP");
#endif

#ifndef HAVE_STRERROR
    prstr("NEED_STRERROR");
#endif

#ifndef HAVE_STRSTR
    prstr("NEED_STRSTR");
#endif

#ifdef HAVE_SYSVSHM
    prstr("HAVE_SYSVSHM");
#endif

#ifdef USE_POSIX_FCNTL
    prstr("LOCKING=POSIX_FCNTL");
#endif
#ifdef USE_FLOCK
    prstr("LOCKING=FLOCK");
#endif
#ifdef USE_LOCKF
    prstr("LOCKING=LOCKF");
#endif
#ifdef USE_LNLOCK
    prstr("LOCKING=LNLOCK");
#endif
#if !defined(USE_POSIX_FCNTL) && !defined(USE_FLOCK) && !defined(USE_LOCK) && !defined(USE_LNLOCK)
    prstr("LOCKING=**NONE**");
#endif

#ifdef STATFS_BSD
    prstr("STATFS_BSD");
#endif

#ifdef STATFS_OSF1
    prstr("STATFS_OSF1");
#endif

#ifdef STATFS_ULTRIX
    prstr("STATFS_ULTRIX");
#endif

#ifdef SETPGRP_VOID
    prstr("SETPGRP_VOID");
#endif

#ifdef ASSERTIONS
    prstr("ASSERTIONS");
#endif

#ifdef AMANDA_DEBUG_DAYS
    prnum("AMANDA_DEBUG_DAYS", AMANDA_DEBUG_DAYS);
#endif

#ifdef BSD_SECURITY
    prstr("BSD_SECURITY");
#endif

#ifdef KRB4_SECURITY
    prstr("KRB4_SECURITY");
#endif

#ifdef KRB5_SECURITY
    prstr("KRB5_SECURITY");
#endif

#ifdef RSH_SECURITY
    prstr("RSH_SECURITY");
#endif

#ifdef USE_AMANDAHOSTS
    prstr("USE_AMANDAHOSTS");
#endif

#ifdef USE_RUNDUMP
    prstr("USE_RUNDUMP");
#endif

    prvar("CLIENT_LOGIN", CLIENT_LOGIN);

#ifdef CHECK_USERID
    prstr("CHECK_USERID");
#endif

#ifdef USE_VERSION_SUFFIXES
    prstr("USE_VERSION_SUFFIXES");
#endif

#ifdef HAVE_GZIP
    prstr("HAVE_GZIP");
#endif

#ifdef COMPRESS_SUFFIX
    prvar("COMPRESS_SUFFIX", COMPRESS_SUFFIX);
#endif

#ifdef COMPRESS_FAST_OPT
    prvar("COMPRESS_FAST_OPT", COMPRESS_FAST_OPT);
#endif

#ifdef COMPRESS_BEST_OPT
    prvar("COMPRESS_BEST_OPT", COMPRESS_BEST_OPT);
#endif

#ifdef UNCOMPRESS_OPT
    prvar("UNCOMPRESS_OPT", UNCOMPRESS_OPT);
#endif

    endline();

    g_printf("  0\n};\n");

    return (0); /* exit */
}
