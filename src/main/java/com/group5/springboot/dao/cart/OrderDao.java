package com.group5.springboot.dao.cart;
// 購物車的連線物件
// 要考慮做DAO Factory嗎？

import java.util.HashSet;
import java.util.List;
import java.util.Set;

import javax.persistence.EntityManager;
import javax.persistence.Query;
import javax.persistence.TypedQuery;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import com.group5.springboot.model.cart.OrderInfo;
import com.group5.springboot.model.product.ProductInfo;
import com.group5.springboot.model.user.User_Info;

@Repository
public class OrderDao implements IOrderDao {
	@Autowired 
	private EntityManager em;
	
	
	@Override
	public List<OrderInfo> selectAll() {
		TypedQuery<OrderInfo> query = em.createQuery("FROM OrderInfo", OrderInfo.class);
		return query.getResultList();
	}
	
	@Override
	public OrderInfo select(OrderInfo orderBean) {
		// ‼ HQL不是用table名而是 Class Name ‼
		TypedQuery<OrderInfo> query = em.createQuery("FROM OrderInfo WHERE o_id = :oid", OrderInfo.class);
		query.setParameter("oid", orderBean.getO_id());
		return query.getSingleResult();
	}

	@Override
	public List<OrderInfo> selectCustom(String hql) {
		TypedQuery<OrderInfo> query = em.createQuery(hql, OrderInfo.class);
		List<OrderInfo> resultList = query.getResultList();
		return resultList;
	}
	
	// Admin - 1
	public List<OrderInfo> selectTop20() {
		TypedQuery<OrderInfo> query = em.createQuery("FROM OrderInfo ob ORDER BY ob.o_id ASC", OrderInfo.class).setMaxResults(20);
		List<OrderInfo> resultList = query.getResultList();
		return resultList;
	}
	
	@Override
		public OrderInfo insert(OrderInfo oBean) {
			
			ProductInfo pBean = em.find(ProductInfo.class, oBean.getP_id());
			User_Info uBean = em.find(User_Info.class, oBean.getU_id());
			
			if(pBean == null) {
				System.out.println("********** 新增失敗：以 p_id (" + oBean.getP_id() + ") 在資料庫中找不到對應的 Product 資料。 **********");
				return null;
			} else if(uBean == null) {
				System.out.println("********** 新增失敗：以 u_id (" + oBean.getU_id() + ") 在資料庫中找不到對應的 User 資料。 **********");
				return null;	
			}
			// 把值補完整
			oBean.setU_firstname(uBean.getU_firstname()); 
			oBean.setU_lastname(uBean.getU_lastname()); 
			oBean.setU_email(uBean.getU_email());
			
			oBean.setP_name(pBean.getP_Name());
			oBean.setP_price(pBean.getP_Price());
			
			// 準備綁定關聯
			Set<OrderInfo> orderSet = new HashSet<OrderInfo>();
			orderSet.add(oBean);
			Set<ProductInfo> productInfoSet = new HashSet<ProductInfo>();
			productInfoSet.add(pBean);
			
			// 互相綁定關聯 (共計 3! = 6 個關聯)
			pBean.setOrderInfoSet(orderSet); // P-Os 關聯
			uBean.setOrderInfoSet(orderSet); // U-Os 關聯
//			uBean.setProductInfoSet(productInfoSet); // U-Ps 關聯
			oBean.setProductInfo(pBean); // O-P 關聯
			oBean.setUser_Info(uBean); // O-U 關聯
//			pBean.setUser_Info(uBean); // P-U 關聯
			
			System.out.println("**********************************************************");
			System.out.println(oBean.toString());
			System.out.println("**********************************************************");
			em.merge(oBean);
	//		em.persist(oBean); // ❓ Admin可以 Index不行，為何RRR
			return oBean;
		}

	// Admin - 2
	public boolean update(OrderInfo newOBean) {
		boolean updateStatus = false;
		// 以PK查出資料庫的 O- / P- / U-Bean
		OrderInfo oBean = em.find(OrderInfo.class, newOBean.getO_id()); 
		ProductInfo pBean = em.find(ProductInfo.class, newOBean.getP_id());
		User_Info uBean = em.find(User_Info.class, newOBean.getU_id());
		
		if(pBean == null) {
			System.out.println("********** 錯誤：以 p_id (" + newOBean.getP_id() + ") 在資料庫中找不到對應的 Product 資料。 **********");
			return updateStatus;
		} else if(uBean == null) {
			System.out.println("********** 錯誤：以 o_id (" + newOBean.getU_id() + ") 在資料庫中找不到對應的 User 資料。 **********");
			return updateStatus;	
		}
		
		if (oBean != null) {
//			resultBean.setO_id         (newBean.getO_id()       ); // 無意義  
			oBean.setP_id         (newOBean.getP_id()       );  
			oBean.setP_name       (newOBean.getP_name()     );  
			oBean.setP_price      (newOBean.getP_price()    );  
			oBean.setU_id         (newOBean.getU_id()       );  
			oBean.setU_firstname  (newOBean.getU_firstname());  
			oBean.setU_lastname   (newOBean.getU_lastname() );  
			oBean.setU_email      (newOBean.getU_email()    );  
			oBean.setO_status     (newOBean.getO_status()   );  
			oBean.setO_date       (newOBean.getO_date()     );  
			oBean.setO_amt        (newOBean.getO_amt()      );  
			// 準備綁定關聯
			Set<OrderInfo> orderSet = new HashSet<OrderInfo>();
			orderSet.add(oBean);
			// 互相綁定關聯
			pBean.setOrderInfoSet(orderSet); // P-Os 關聯
			uBean.setOrderInfoSet(orderSet); // U-Os 關聯
			oBean.setProductInfo(pBean); // O-P 關聯
			oBean.setUser_Info(uBean); // O-U 關聯
			
			em.merge(oBean); 
		} else {
			System.out.println("*** Order with O_ID = " + newOBean.getO_id() + "doesn't exist in the database :^) ***");
		}
		updateStatus = true;
		return updateStatus;
	}
	
	public boolean delete(OrderInfo orderBean) {
		// 方法⓵ > 執行SELECT + DELETE
/**		Order resultBean = em.find(Order.class, orderBean.getO_id());
		if (resultBean != null) {
			session.delete(orderBean); 
		}*/
		// 方法⓶ > HQL
		Query query = em.createQuery("DELETE OrderInfo WHERE o_id = :oid");
		query.setParameter("oid", orderBean.getO_id());
		int deletedNum = query.executeUpdate();
		System.out.println("You deleted " + deletedNum + " row(s) from order_info table.");
		return (deletedNum == 0)? false : true;
	}

}