/*
File: utl-smtp-email.sql
Purpose: Plantilla para envío de correo usando UTL_SMTP en Oracle.
Author: Jaiber Diaz
Date: 2026-05-27
Bases de Datos 2 — UEB
*/

SET SERVEROUTPUT ON;

DECLARE
  vv_smtp_host VARCHAR2(100) := 'smtp.example.com';
  vn_smtp_port INTEGER := 587;
  vv_sender VARCHAR2(200) := 'sender@example.com';
  vv_recipient VARCHAR2(200) := 'recipient@example.com';
  vv_subject VARCHAR2(200) := 'Prueba UTL_SMTP';
  vv_body VARCHAR2(4000) := 'Hola, este es un correo de prueba desde Oracle.';
  v_conn UTL_SMTP.CONNECTION;
BEGIN
  v_conn := UTL_SMTP.OPEN_CONNECTION(vv_smtp_host, vn_smtp_port);
  UTL_SMTP.HELO(v_conn, vv_smtp_host);
  UTL_SMTP.MAIL(v_conn, vv_sender);
  UTL_SMTP.RCPT(v_conn, vv_recipient);
  UTL_SMTP.DATA(
    v_conn,
    'Subject: ' || vv_subject || UTL_TCP.CRLF ||
    'To: ' || vv_recipient || UTL_TCP.CRLF ||
    'From: ' || vv_sender || UTL_TCP.CRLF ||
    UTL_TCP.CRLF ||
    vv_body
  );
  UTL_SMTP.QUIT(v_conn);
END;
/
