CREATE TABLE olxga_irn.cur_exchange (r030 NUMBER,
                                     txt VARCHAR2(100),
                                     rate NUMBER,
                                     cur VARCHAR2(100),
                                     exchangedate DATE,
                                     change_date DATE DEFAULT SYSDATE);
