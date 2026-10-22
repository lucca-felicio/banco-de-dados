CREATE TABLE reservas (
    id SERIAL PRIMARY KEY,
    numero_quarto INT NOT NULL,
    data_checkin DATE NOT NULL,
    data_checkout DATE NOT NULL,
    valor_diaria NUMERIC(10, 2) NOT NULL,
    valor_total NUMERIC(10, 2)
);

CREATE OR REPLACE FUNCTION fn_processa_reserva()
RETURNS TRIGGER AS $$
DECLARE
    dias_estadia INT;
BEGIN
    IF NEW.data_checkout <= NEW.data_checkin THEN
        RAISE EXCEPTION 'A data de check-out (%) precisa ser posterior à data de check-in (%)!', 
            NEW.data_checkout, NEW.data_checkin;
    END IF;
    dias_estadia := NEW.data_checkout - NEW.data_checkin;
    NEW.valor_total := dias_estadia * NEW.valor_diaria;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger vinculada
CREATE TRIGGER trg_processa_reserva
BEFORE INSERT OR UPDATE ON reservas
FOR EACH ROW
EXECUTE FUNCTION fn_processa_reserva();