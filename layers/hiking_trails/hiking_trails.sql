
-- etldoc: osm_hiking_trails_linestring ->  hiking_trails
CREATE OR REPLACE VIEW hiking_trails AS (
    SELECT rm.geometry,
        r.route AS class,
        rm.name,
        rm.name_en
    FROM osm_hiking_trails_linestring as rm
    JOIN osm_hiking_trails_routes as r on r.osm_id = rm.osm_id
    WHERE r.route IN ('hiking', 'foot')
);

CREATE OR REPLACE FUNCTION layer_hiking_trails(bbox geometry, zoom_level int)
RETURNS TABLE(geometry geometry, class text, name text, name_en text) AS $$
    SELECT geometry, class,
        NULLIF(name, '') AS name,
        COALESCE(NULLIF(name_en, ''), name) AS name_en
    FROM (
        -- etldoc: hiking_trails ->  layer_hiking_trails:z3
        SELECT * FROM hiking_trails
    ) AS zoom_levels
    WHERE geometry && bbox;
$$ LANGUAGE SQL IMMUTABLE;
