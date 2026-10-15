-- Parámetros globales: la API los edita y guarda cada cambio para poder revertirlo
GRANT UPDATE ON TABLE iam.security_configurations TO drivique_app;
GRANT SELECT, INSERT, UPDATE ON TABLE iam.security_configuration_changes TO drivique_app;
