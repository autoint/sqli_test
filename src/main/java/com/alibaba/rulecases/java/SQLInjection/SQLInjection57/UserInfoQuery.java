package com.alibaba.rulecases.java.SQLInjection.SQLInjection57;
import java.util.Date;

public class UserInfoQuery  {
	public UserInfoQuery(String orderBy,String id){
		this.orderBy = orderBy;
		this.id = id;
	}

	private String orderBy ;

	private Date gmtCreate;

	private String id;

	public String getOrderBy() {
		return orderBy;
	}

	public void setOrderBy(String orderBy) {
		this.orderBy = orderBy;
	}

	public Date getGmtCreate() {
		return gmtCreate;
	}

	public void setGmtCreate(Date gmtCreate) {
		this.gmtCreate = gmtCreate;
	}

	public String getId() {
		return id;
	}

	public void setId(String id) {
		this.id = id;
	}
}
