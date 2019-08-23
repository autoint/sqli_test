package com.alibaba.rulecases.java.SQLInjection.SQLInjection18;

import com.alibaba.citrus.turbine.dataresolver.Param;
import com.alibaba.security.SecurityUtil;

public class HttpEntrance {

	private UserInfoDAO userInfoDAO;

	public void execute(@Param("param") String param) throws Exception {
		UserInfoQuery query = new UserInfoQuery();
		String orderby = SecurityUtil.trimSql(param);
		query.setOrderBy(orderby);
		userInfoDAO.query(query);
	}
}
