# netperf benchmark

## Prerequisite
- macOS (we tested with 10.12 and 10.13)
- netperf2 (https://github.com/HewlettPackard/netperf)
- frankenlibc (https://github.com/libos-nuse/frankenlibc)
- noah (https://github.com/linux-noah/noah or `brew install linux-noah/noah/noah`)
- docker for macOS (https://www.docker.com/docker-mac, tested with 18.03.0-ce)
- gnuplot
- datamash

## Setup

We needed to patch to netperf2 so that our experiment successfully run without any errors.

```
diff --git a/config.sub b/config.sub
index 1c366df..966cfd6 100755
--- a/config.sub
+++ b/config.sub
@@ -286,6 +286,8 @@ case $basic_machine in
 		;;
 	m88110 | m680[12346]0 | m683?2 | m68360 | m5200 | v70 | w65 | z8k)
 		;;
+	x86_64-rumprun)
+		;;
 
 	# We use `pc' rather than `unknown'
 	# because (1) that's what they normally are, and
diff --git a/src/netlib.c b/src/netlib.c
index 62cbe15..51c1461 100644
--- a/src/netlib.c
+++ b/src/netlib.c
@@ -55,6 +55,10 @@ char    netlib_id[]="\
 
 #ifdef HAVE_CONFIG_H
 #include <config.h>
+#endif
+
+#ifdef __linux__
+#define __linux
 #endif
 
  /* It would seem that most of the includes being done here from
diff --git a/src/netserver.c b/src/netserver.c
index 787f22d..f893a41 100644
--- a/src/netserver.c
+++ b/src/netserver.c
@@ -184,7 +184,7 @@ char	netserver_id[]="\
 #if !defined(PATH_MAX)
 #define PATH_MAX MAX_PATH
 #endif
-char     FileName[PATH_MAX];
+char     *FileName;
 
 char     listen_port[10];
 
@@ -257,7 +257,7 @@ open_debug_file()
   if (where != NULL) fflush(where);
   if (suppress_debug) {
     FileName = NETPERF_NULL;
-    where = fopen(Filename, "w");
+    where = fopen(FileName, "w");
   } else {
     snprintf(FileName, sizeof(FileName), "%s" FILE_SEP "%s",
              DEBUG_LOG_FILE_DIR, DEBUG_LOG_FILE);
diff --git a/src/nettest_bsd.c b/src/nettest_bsd.c
index 3589d29..cedb89b 100644
--- a/src/nettest_bsd.c
+++ b/src/nettest_bsd.c
@@ -3,6 +3,9 @@ char	nettest_id[]="\
 @(#)nettest_bsd.c (c) Copyright 1993-2012 Hewlett-Packard Co. Version 2.6.0";
 #endif /* lint */
 
+#ifdef __linux__
+#define __linux
+#endif
 
 /****************************************************************/
 /*								*/
diff --git a/src/nettest_omni.c b/src/nettest_omni.c
index 852eeb1..973075f 100644
--- a/src/nettest_omni.c
+++ b/src/nettest_omni.c
@@ -2,6 +2,10 @@
 #include <config.h>
 #endif
 
+#ifdef __linux__
+#define __linux
+#endif
+
 #ifdef WANT_OMNI
 char nettest_omni_id[]="\
 @(#)nettest_omni.c (c) Copyright 2008-2012 Hewlett-Packard Co. Version 2.6.0";

```

## How to conduct an experiment

```
% ./netperf-bench.sh
```

## Result

You should have results in `${DATE}/out` directory.

The following is an example plot of the result obtained with the script.

![](https://raw.githubusercontent.com/libos-nuse/nuse-msmt/master/apsys/netperf/tcp-stream-example.png)