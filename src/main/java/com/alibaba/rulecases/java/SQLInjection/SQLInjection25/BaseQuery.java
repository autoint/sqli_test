package com.alibaba.rulecases.java.SQLInjection.SQLInjection25;

import com.alibaba.security.SecurityUtil;

public class BaseQuery {
	private String orderBy;

	public String getOrderBy() {
		return SecurityUtil.trimSql(orderBy);
	}

	public void setOrderBy(String orderBy) {
		this.orderBy = orderBy;
	}
}
