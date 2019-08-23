package com.alibaba.rulecases.java.SQLInjection.SQLInjection17;

import com.alibaba.citrus.turbine.dataresolver.Param;
import com.alibaba.security.SecurityUtil;

public class HttpEntrance {

	private UserInfoDAO userInfoDAO;

	public void execute(@Param("param") String param) throws Exception {
		UserInfoQuery query = new UserInfoQuery();
		query.setOrderBy(SecurityUtil.trimSql(param));
		userInfoDAO.query(query);
	}
}
