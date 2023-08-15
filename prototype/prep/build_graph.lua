local Set = require("data_structs.Set")

local function build_graph()
    local add_resever_edges,
    add_reverse_edge,
    get_start_node

    function add_resever_edges()
        for _, tech in pairs(data.raw.technology) do
            if tech.prerequisites ~= nil then
                add_reverse_edge(tech.prerequisites, tech.name)
            end
        end
    end

    function add_reverse_edge(prerequisites, name)
        for _, prerequisite in pairs(prerequisites) do
            local tech = data.raw.technology[prerequisite]
            if tech.postrequisites == nil then
                tech["postrequisites"] = {}
            end
            table.insert(tech.postrequisites, name)
        end
    end

    function get_start_node()
        local start_node = Set.init()
        for key, tech in pairs(data.raw.technology) do
            if key == "automation" then
                print("stop")
            end
            if tech.prerequisites == nil then
                start_node:add(tech.name)
            end
        end
        return start_node
    end

    add_resever_edges()
    return get_start_node()
end

return build_graph()
