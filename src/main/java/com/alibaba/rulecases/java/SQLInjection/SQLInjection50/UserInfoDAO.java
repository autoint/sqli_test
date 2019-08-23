package com.alibaba.rulecases.java.SQLInjection.SQLInjection50;
import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.SelectProvider;
import org.apache.ibatis.jdbc.SQL;

public interface UserInfoDAO {
	@SelectProvider(type = SqlProvider.class, method = "query")
	List<UserInfoDAO> query(@Param("userInfoQuery") UserInfoQuery userInfoQuery);

	class SqlProvider {
		public String query(Map<String, Object> params) {
			final UserInfoQuery userInfoQuery = (UserInfoQuery)params.get("userInfoQuery");
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
}
