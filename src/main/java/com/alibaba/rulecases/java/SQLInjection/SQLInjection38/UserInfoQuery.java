package com.alibaba.rulecases.java.SQLInjection.SQLInjection38;

import java.util.Date;

public class UserInfoQuery  {

	private Date gmtCreate;

	private Long id;

	private OrderSortEnum orderBy = OrderSortEnum.GMT_CREATE_DESC;

	public String getOrderBy() {
		return orderBy.getValue();
	}

	public void setOrderBy(String orderBy) {
		this.orderBy = OrderSortEnum.valueOf(orderBy);
	}

	public Date getGmtCreate() {
		return gmtCreate;
	}

	public void setGmtCreate(Date gmtCreate) {
		this.gmtCreate = gmtCreate;
	}

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}
}

enum OrderSortEnum {

	SKU_CODE_ASC("sku_code asc"),

	GMT_CREATE_DESC("gmt_create DESC");

	private String value;

	OrderSortEnum(String value) {
		this.value = value;
	}

	public String getValue() {
		return value;
	}
}