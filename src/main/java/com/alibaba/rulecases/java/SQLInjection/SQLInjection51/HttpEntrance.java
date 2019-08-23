package com.alibaba.rulecases.java.SQLInjection.SQLInjection51;

import java.util.HashMap;
import java.util.Map;

import com.alibaba.citrus.turbine.dataresolver.Param;

public class HttpEntrance {
	private ResourceTextDAO resourceTextDAO;

	public void execute(@Param("param") String param) throws Exception {
		Map map = new HashMap();
		map.put("shopIds",param);
		resourceTextDAO.queryWdkResourceTextCountByModuleId(map);
	}
}
