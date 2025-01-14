CREATE OR REPLACE PROCEDURE atualizar_cadsus_pend_envio (
    nr_seq_interno_p   NUMBER,
    ie_pendente_p      VARCHAR2,
    nm_usuario_p       VARCHAR2
)
    IS
BEGIN
    UPDATE cadsus_pend_envio
        SET
            ie_pendente = ie_pendente_p,
            dt_atualizacao = sysdate,
            nm_usuario = nm_usuario_p
    WHERE
        nr_sequencia = nr_seq_interno_p;

    COMMIT;
END atualizar_cadsus_pend_envio;
/