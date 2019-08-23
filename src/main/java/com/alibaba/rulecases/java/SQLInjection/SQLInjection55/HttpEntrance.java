package com.alibaba.rulecases.java.SQLInjection.SQLInjection55;

import java.util.HashMap;
import java.util.Map;

import com.alibaba.citrus.turbine.dataresolver.Param;
import com.alibaba.security.SecurityUtil;

public class HttpEntrance {
	private ResourceTextDAO resourceTextDAO;

	public void execute(@Param("param") String param) throws Exception {
		Map map = new HashMap();
		String newParam = SecurityUtil.trimSql(param);
		map.put("shopIds",newParam);
		resourceTextDAO.queryWdkResourceTextCountByModuleId(map);
	}
}
