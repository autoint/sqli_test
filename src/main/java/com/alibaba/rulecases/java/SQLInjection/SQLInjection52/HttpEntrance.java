package com.alibaba.rulecases.java.SQLInjection.SQLInjection52;

import com.alibaba.citrus.turbine.dataresolver.Param;
import com.alibaba.security.SecurityUtil;


public class HttpEntrance {

	private UserInfoDAO userInfoDAO;

	public void execute(@Param("param") String param) throws Exception {
		UserInfoQuery query = new UserInfoQuery();
		query.setOrderBy(param);
		trimField(query);
		fun(query);
	}

	public void fun(UserInfoQuery query){
		userInfoDAO.query(query);
	}

	void trimField(UserInfoQuery query){
		query.orderBy = SecurityUtil.trimSql(query.getOrderBy());
		//query.setOrderBy(SecurityUtil.trimSql(query.getOrderBy()));
	}
}
