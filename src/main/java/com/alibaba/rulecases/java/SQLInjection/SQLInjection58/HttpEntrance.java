package com.alibaba.rulecases.java.SQLInjection.SQLInjection58;

import com.alibaba.citrus.turbine.dataresolver.Param;


public class HttpEntrance {

	private UserInfoDAO userInfoDAO;

	public void execute(@Param("param") String param) throws Exception {
		UserInfoQuery query = new UserInfoQuery("abc",param);
		userInfoDAO.query(query);
	}
}
