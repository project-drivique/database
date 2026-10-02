INSERT INTO contract.inspection_checklist_items (name, description) VALUES
    ('Llantas', 'Estado de neumáticos, labrado y presión de inflado'),
    ('Luces', 'Funcionamiento de luces altas, bajas, direccionales y stop'),
    ('Carrocería', 'Inspección de rayones, abolladuras, pintura y piezas exteriores'),
    ('Espejos', 'Estado y ajuste de retrovisores laterales y central')
ON CONFLICT (name) DO NOTHING;
