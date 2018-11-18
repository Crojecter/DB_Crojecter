-- 20181109 수정
-- 20181113 댓글DB CREFMID 컬럼 추가 & 프로젝트DB JTAG 컬럼 추가
-- 20181118 PROJECT_VIEW TABLE 추가

---- 1-1. 회원 상태 DB ----
CREATE TABLE M_STATUS(
    MSID NUMBER PRIMARY KEY,
    MSTATUS VARCHAR2(10) NOT NULL
);
INSERT INTO M_STATUS VALUES(1, '활성');
INSERT INTO M_STATUS VALUES(2, '비활성');
INSERT INTO M_STATUS VALUES(3, '탈퇴');


---- 1. 회원 DB ----
CREATE SEQUENCE SEQ_MID; -- 시퀀스
CREATE TABLE MEMBER(
    MID NUMBER PRIMARY KEY,
    MPROFILE VARCHAR2(1000),
    MEMAIL VARCHAR2(300) NOT NULL,
    MPWD VARCHAR2(200) NOT NULL,
    MNAME VARCHAR2(30) NOT NULL,
    MDATE DATE DEFAULT SYSDATE,
    MHODU NUMBER DEFAULT 0,
    MSID NUMBER DEFAULT 1 CHECK (MSID IN (1, 2, 3)),
    FOREIGN KEY (MSID) REFERENCES M_STATUS(MSID),
    CONSTRAINT UN_MEMBER UNIQUE (MEMAIL, MNAME)
);

ALTER TABLE MEMBER ADD UNIQUE(MEMAIL);
ALTER TABLE MEMBER ADD UNIQUE(MNAME);


---- 2. 게시판 DB ----
-- BTYPE 1:공지사항 2:갤러리 3:프로젝트
CREATE SEQUENCE SEQ_BID; -- 시퀀스
CREATE TABLE BOARD(
    BID NUMBER PRIMARY KEY,
    BTYPE NUMBER NOT NULL CHECK (BTYPE IN (1, 2, 3)),
    BTITLE VARCHAR2(100) NOT NULL,
    BCONTENT VARCHAR2(4000) NOT NULL,
    BCOUNT NUMBER DEFAULT 0,
    BDATE DATE DEFAULT SYSDATE,
    BSTATUS VARCHAR2(1) DEFAULT 'Y' CHECK (BSTATUS IN ('Y', 'N')),
    BRCOUNT NUMBER DEFAULT 0,
    BWRITER NUMBER NOT NULL,
    FOREIGN KEY (BWRITER) REFERENCES MEMBER(MID)
);

---- 3-1. 갤러리 보조 DB ----
CREATE TABLE CCL(
    CCLID NUMBER PRIMARY KEY,
    CCLNAME VARCHAR2(50) NOT NULL
);
INSERT INTO CCL VALUES(1, 'BY');
INSERT INTO CCL VALUES(2, 'BY-NC');
INSERT INTO CCL VALUES(3, 'BY-ND');
INSERT INTO CCL VALUES(4, 'BY-SA');
INSERT INTO CCL VALUES(5, 'BY-NC-SA');
INSERT INTO CCL VALUES(6, 'BY-NC-ND');

CREATE TABLE GCATEGORY(
    GCATEGORYID NUMBER PRIMARY KEY,
    GCATEGORYNAME VARCHAR2(10)
);
INSERT INTO GCATEGORY VALUES(1, '텍스트');
INSERT INTO GCATEGORY VALUES(2, '이미지');
INSERT INTO GCATEGORY VALUES(3, '오디오');
INSERT INTO GCATEGORY VALUES(4, '비디오');

---- 3. 갤러리 DB ----
CREATE SEQUENCE SEQ_GID; -- 시퀀스
CREATE TABLE GALLERY(
    GID NUMBER PRIMARY KEY,
    GCATEGORYID NUMBER NOT NULL CHECK (GCATEGORYID IN (1, 2, 3, 4)),
    GTAG VARCHAR2(300),
    GLIKE NUMBER DEFAULT 0,
    BID NUMBER NOT NULL,
    CCLID NOT NULL,
    FOREIGN KEY (BID) REFERENCES BOARD(BID),
    FOREIGN KEY (CCLID) REFERENCES CCL(CCLID),
    FOREIGN KEY (GCATEGORYID) REFERENCES GCATEGORY(GCATEGORYID)
);


---- 4. 프로젝트 DB ----
CREATE SEQUENCE SEQ_JID; -- 시퀀스
CREATE TABLE PROJECT(
    JID NUMBER PRIMARY KEY,
    JEND DATE NOT NULL,
    BID NUMBER NOT NULL,
    JTAG VARCHAR2(300),
    FOREIGN KEY (BID) REFERENCES BOARD(BID)
);


---- 5. 첨부파일 DB ----
CREATE SEQUENCE SEQ_AFID; -- 시퀀스
CREATE TABLE ATTACHEDFILE(
    FID NUMBER PRIMARY KEY,
    FNAME VARCHAR2(50) NOT NULL,
    FPATH VARCHAR2(1000) NOT NULL,
    FLEVEL NUMBER DEFAULT 1 CHECK (FLEVEL IN(1, 2)),
    BID NUMBER NOT NULL,
    FOREIGN KEY (BID) REFERENCES BOARD(BID)
);


---- 6. 댓글(코멘트) DB ----
CREATE SEQUENCE SEQ_CID; -- 시퀀스
CREATE TABLE BOARDCOMMENT(
    CID NUMBER PRIMARY KEY,
    CCONTENT VARCHAR2(600) NOT NULL,
    CDATE DATE DEFAULT SYSDATE,
    CSTATUS VARCHAR2(1) DEFAULT 'Y' CHECK (CSTATUS IN ('Y', 'N')),
    BID NUMBER NOT NULL,
    CWRITER NUMBER NOT NULL,
    CRCOUNT NUMBER DEFAULT 0,
    CREFMID NUMBER,
    FOREIGN KEY (BID) REFERENCES BOARD(BID),
    FOREIGN KEY (CWRITER) REFERENCES MEMBER(MID),
    FOREIGN KEY (CREFMID) REFERENCES MEMBER(MID)
);


---- 7-1. 결제 보조 DB ---- 
CREATE TABLE PMONEY(
    PMONEY_ID NUMBER PRIMARY KEY,
    PMONEY NUMBER NOT NULL,
    PHODU NUMBER NOT NULL
);
INSERT INTO PMONEY VALUES(1, 5500, 50);
INSERT INTO PMONEY VALUES(2, 11000, 100);
INSERT INTO PMONEY VALUES(3, 33000, 300);
INSERT INTO PMONEY VALUES(4, 55000, 500);

---- 7. 결제 DB ----
CREATE SEQUENCE SEQ_PID; -- 시퀀스
CREATE TABLE PAYMENT(
    PID NUMBER PRIMARY KEY,
    PMONEY NUMBER NOT NULL CHECK (PMONEY IN (1, 2, 3, 4)),
    PDATE DATE DEFAULT SYSDATE,
    MID NUMBER NOT NULL,
    FOREIGN KEY (MID) REFERENCES MEMBER(MID),
    FOREIGN KEY (PMONEY) REFERENCES PMONEY(PMONEY_ID)
);


---- 8-1. 후원 호두 갯수 DB ----
CREATE TABLE SHODU(
    SHODU_ID NUMBER PRIMARY KEY,
    SHODU NUMBER NOT NULL
);
INSERT INTO SHODU VALUES(1, 10);
INSERT INTO SHODU VALUES(2, 30);
INSERT INTO SHODU VALUES(3, 40);
INSERT INTO SHODU VALUES(4, 100);

---- 8. 후원 DB ----
CREATE SEQUENCE SEQ_SID; -- 시퀀스
CREATE TABLE SPON(
    SID NUMBER PRIMARY KEY,
    SHODU NUMBER NOT NULL CHECK (SHODU IN (1, 2, 3, 4)),
    SDATE DATE DEFAULT SYSDATE,
    SGIVERID NUMBER NOT NULL,
    SRECEIVERID NUMBER NOT NULL,
    FOREIGN KEY (SGIVERID) REFERENCES MEMBER(MID),
    FOREIGN KEY (SRECEIVERID) REFERENCES MEMBER(MID),
    FOREIGN KEY (SHODU) REFERENCES SHODU(SHODU_ID)
);


---- 9-1. 신고사유 DB ----
CREATE TABLE R_REASON(
    RRID NUMBER PRIMARY KEY,
    RCONTENT VARCHAR2(100)
);
INSERT INTO R_REASON VALUES(1, '부적절한 홍보성 게시물');
INSERT INTO R_REASON VALUES(2, '음란성 또는 청소년에게 부적합한 내용');
INSERT INTO R_REASON VALUES(3, '특정인 대상의 비방/욕설');
INSERT INTO R_REASON VALUES(4, '저작권 침해');
INSERT INTO R_REASON VALUES(5, '기타');

---- 9. 신고 DB ----
CREATE SEQUENCE SEQ_RID; -- 시퀀스
CREATE TABLE REPORT(
    RID NUMBER PRIMARY KEY,
    RREASON NUMBER NOT NULL,
    RETC VARCHAR2(50),
    RDATE DATE DEFAULT SYSDATE,
    MID NUMBER NOT NULL,
    CID NUMBER,
    BID NUMBER NOT NULL,
    FOREIGN KEY (MID) REFERENCES MEMBER(MID),
    FOREIGN KEY (CID) REFERENCES BOARDCOMMENT(CID),
    FOREIGN KEY (BID) REFERENCES BOARD(BID)
);


---- 10. 팔로우 DB ----
CREATE SEQUENCE SEQ_FID; -- 시퀀스
CREATE TABLE FOLLOW(
    FID NUMBER PRIMARY KEY,
    FOLLOWERID NUMBER NOT NULL,
    FOLLOWID NUMBER NOT NULL,
    FOREIGN KEY (FOLLOWERID) REFERENCES MEMBER(MID),
    FOREIGN KEY (FOLLOWID) REFERENCES MEMBER(MID)
);


---- 11. 좋아요 DB ----
CREATE SEQUENCE SEQ_LID; -- 시퀀스
CREATE TABLE LIKEIT(
    LID NUMBER PRIMARY KEY,
    MID NUMBER NOT NULL,
    BID NUMBER NOT NULL,
    FOREIGN KEY (MID) REFERENCES MEMBER(MID),
    FOREIGN KEY (BID) REFERENCES BOARD(BID)
);


---- 12. 알람 DB ----
CREATE SEQUENCE SEQ_AID; -- 시퀀스
CREATE TABLE ALARM(
    AID NUMBER PRIMARY KEY,
    MID NUMBER NOT NULL,
    AMSG VARCHAR2(40) NOT NULL,
    ADATE DATE DEFAULT SYSDATE,
    AFLAG VARCHAR2(2) DEFAULT 'Y' CHECK (AFLAG IN ('Y', 'N')),
    FOREIGN KEY (MID) REFERENCES MEMBER(MID)
);


-------------------------------------------------------------------------

---- 갤러리 뷰 생성 ----
CREATE OR REPLACE VIEW GALLERY_VIEW
AS 
SELECT G.GID, G.GCATEGORYID, GTAG, GLIKE, G.CCLID, B.*, M.MPROFILE, M.MNAME, GC.GCATEGORYNAME, C.CCLNAME
FROM GALLERY G
JOIN BOARD B ON (G.BID=B.BID)
JOIN MEMBER M ON (B.BWRITER = M.MID)
JOIN GCATEGORY GC ON (G.GCATEGORYID = GC.GCATEGORYID)
JOIN CCL C ON (G.CCLID = C.CCLID)
ORDER BY G.GID
WITH READ ONLY;
                                         
---- 프로젝트 뷰 생성 ----
                                         
CREATE OR REPLACE VIEW PROJECT_VIEW
AS 
SELECT J.JID, J.JEND, J.JTAG, B.*, M.MPROFILE, M.MNAME, CEIL(JEND-SYSDATE) DDAY
FROM PROJECT J
JOIN BOARD B ON (J.BID=B.BID)
JOIN MEMBER M ON (B.BWRITER = M.MID)
ORDER BY J.JID
WITH READ ONLY;




COMMIT;

