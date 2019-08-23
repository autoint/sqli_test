package com.alibaba.rulecases.java.SQLInjection.SQLInjection33;

import com.alibaba.citrus.turbine.dataresolver.Param;


public class HttpEntrance {

	private UserInfoDAO userInfoDAO;

	public void execute(@Param("param") String param) throws Exception {
		UserInfoQuery query = new UserInfoQuery();
		query.setOrderBy(param);
		fun(query);
	}

	public void fun(UserInfoQuery query){
		userInfoDAO.query(query);
	}
}
