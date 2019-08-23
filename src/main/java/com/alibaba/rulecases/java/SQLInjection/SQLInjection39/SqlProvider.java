package com.alibaba.rulecases.java.SQLInjection.SQLInjection39;
import java.util.Map;

import org.apache.ibatis.jdbc.SQL;

public class SqlProvider {
	public String query(Map<String, Object> params) {
		final UserInfoQuery userInfoQuery = (UserInfoQuery) params.get("userInfoQuery");
		return new SQL(){
			{
				SELECT("a.*, b.department, b.product_code");
				FROM("group_billing_share AS a, group_product AS b");
				WHERE(" a.deleted=0 ");
				AND();
				WHERE(" a.group_product_id=b.id ");
				AND();
				WHERE(" a.group_product_id=" + userInfoQuery.getOrderBy() + " ");
			}
		}.toString();
	}
}
