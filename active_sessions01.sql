SELECT /*+  RULE */
         DISTINCT
          SESS.inst_id,
          SESS.sid,
         SESS.SERIAL#,
         SESS.logon_time,
         SESS.LAST_CALL_ET,
         ROUND (SM.ELAPSED_TIME / 1e6, 0) "DURATION",
         SM.FETCHES,
            TO_CHAR (FLOOR (sess.last_call_et / 86400), '999')
         || ' d '
         || TRIM (
               TO_CHAR (FLOOR (MOD (sess.last_call_et, 86400) / 3600), '00'))
         || ' hr '
         || TRIM (TO_CHAR (FLOOR (MOD (sess.last_call_et, 3600) / 60), '00'))
         || ' min '
            DUR,
         SESS.machine,
         SESS.PROCESS "PROCESS",
         NVL (SESS.sql_id, sm.sql_id) SQL_ID,
         sess.event,
         SM.SQL_PLAN_HASH_VALUE PHV,
         SESS.program,
         sess.action,
         sess.module,
         sess.client_identifier,
         SESS.username,
         SESS.osuser,
         SESS.STATUS,
         ROUND (SM.APPLICATION_WAIT_TIME / 1e6, 2) "APP_WT(s)",
         ROUND (SM.CLUSTER_WAIT_TIME / 1e6, 2) "CLUSTER_WT(s)",
         ROUND (SM.CONCURRENCY_WAIT_TIME / 1e6, 2) "CONCURRENCY_WT(s)",
         ROUND (SM.USER_IO_WAIT_TIME / 1e6, 2) "USERIO_WT(s)",
         ROUND (SM.CPU_TIME / 1e6, 2) "CPU_TIME(s)",
         ROUND (SM.BUFFER_GETS) "LIO",
         SM.PX_SERVERS_ALLOCATED "PX_THREADS",
         SESS.SQL_CHILD_NUMBER,
         SM.KEY,
            'exec sys.tsdappdba.kill_session_rac('''
         || sess.sid
         || ''','''
         || sess.serial#
         || ''','''
         || sess.inst_id
         || ''');  '
            Kill_command
    FROM GV$SESSION SESS, GV$SQL_MONITOR SM
   WHERE     1 = 1
         AND SESS.username IS NOT NULL
         AND SESS.INST_ID = SM.INST_ID(+)
         AND SESS.SID = SM.SID(+)
         AND SESS.SERIAL# = SM.SESSION_SERIAL#(+)
         AND SESS.SQL_EXEC_ID = SM.SQL_EXEC_ID(+)
         AND SESS.SQL_EXEC_START = SM.SQL_EXEC_START (+)
         AND (sess.status = 'ACTIVE' or sm.status='EXECUTING')
ORDER BY LAST_CALL_ET DESC;