<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html>
<head>
    <title>군산대 커뮤니티 회원가입</title>
    <link rel="stylesheet" href="/common/css/login.css" />
    <style>
        .login-form input[type="email"],
        .login-form input[type="text"],
        .login-form input[type="password"] {
            width: 100%;
            padding: 10px;
            margin-bottom: 5px;
            border: 1px solid #ccc;
            border-radius: 6px;
            box-sizing: border-box;
            font-size: 14px;
        }
        
        .error-message {
            color: #e74c3c;
            font-size: 12px;
            margin-bottom: 10px;
            display: none;
            text-align: left;
        }
        
        .input-group {
            margin-bottom: 10px;
        }
    </style>
</head>
<body>
    <div class="login-container">
        <h2 class="title">회원가입</h2>
        <form action="db/joinAction.jsp" method="post" class="login-form" id="registerForm" onsubmit="return validateForm()">
            <div class="input-group">
                <input type="text" name="userId" id="userId" placeholder="학번" required pattern="[0-9]{7}" />
                <div id="userIdError" class="error-message">학번은 7자리 숫자여야 하며, 앞 2자리는 입학년도여야 합니다.</div>
            </div>
            
            <div class="input-group">
                <input type="password" name="password" id="password" placeholder="비밀번호" required pattern="^(?=.*[A-Z])(?=.*[!@#$%^&*])(?=.*[0-9])(?=.*[a-z]).{7,14}$" />
                <div id="passwordError" class="error-message">비밀번호는 7~14자 사이이며, 대문자, 소문자, 숫자, 특수문자를 각각 1개 이상 포함해야 합니다.</div>
            </div>
            
            <div class="input-group">
                <input type="text" name="name" id="name" placeholder="이름" required pattern="^[가-힣]+$" />
                <div id="nameError" class="error-message">이름은 한글만 입력 가능합니다.</div>
            </div>
            
            <div class="input-group">
                <input type="email" name="email" id="email" placeholder="이메일" required />
                <div id="emailError" class="error-message">이메일은 학번@kunsan.ac.kr 형식이어야 합니다.</div>
            </div>
            
            <input type="submit" value="회원가입" class="login-btn" />
        </form>
        <div class="link-box">
            <a href="login.jsp">로그인으로 돌아가기</a>
        </div>
    </div>
    
    <script>
        function validateForm() {
            let isValid = true;
            const currentYear = new Date().getFullYear();
            
            // 학번 검증
            const userIdInput = document.getElementById('userId');
            const userIdError = document.getElementById('userIdError');
            const userId = userIdInput.value;
            
            if (!/^\d{7}$/.test(userId)) {
                userIdError.style.display = 'block';
                userIdError.textContent = '학번은 7자리 숫자여야 합니다.';
                isValid = false;
            } else {
                const yearPrefix = parseInt(userId.substring(0, 2));
                const fullYear = yearPrefix < 50 ? 2000 + yearPrefix : 1900 + yearPrefix;
                
                if (fullYear < 1950 || fullYear > currentYear) {
                    userIdError.style.display = 'block';
                    userIdError.textContent = '유효하지 않은 입학년도입니다.';
                    isValid = false;
                } else {
                    userIdError.style.display = 'none';
                }
            }
            
            // 비밀번호 검증
            const passwordInput = document.getElementById('password');
            const passwordError = document.getElementById('passwordError');
            const password = passwordInput.value;
            
            if (!/^(?=.*[A-Z])(?=.*[!@#$%^&*])(?=.*[0-9])(?=.*[a-z]).{7,14}$/.test(password)) {
                passwordError.style.display = 'block';
                isValid = false;
            } else {
                passwordError.style.display = 'none';
            }
            
            // 이름 검증
            const nameInput = document.getElementById('name');
            const nameError = document.getElementById('nameError');
            const name = nameInput.value;
            
            if (!/^[가-힣]+$/.test(name)) {
                nameError.style.display = 'block';
                isValid = false;
            } else {
                nameError.style.display = 'none';
            }
            
            // 이메일 검증
            const emailInput = document.getElementById('email');
            const emailError = document.getElementById('emailError');
            const email = emailInput.value;
            const expectedEmail = userId + '@kunsan.ac.kr';
            
            if (email !== expectedEmail) {
                emailError.style.display = 'block';
                isValid = false;
            } else {
                emailError.style.display = 'none';
            }
            
            return isValid;
        }
        
        // 입력 필드에 입력할 때마다 유효성 검사
        document.getElementById('userId').addEventListener('input', function() {
            const userIdError = document.getElementById('userIdError');
            const userId = this.value;
            
            if (userId.length === 7 && /^\d{7}$/.test(userId)) {
                const yearPrefix = parseInt(userId.substring(0, 2));
                const currentYear = new Date().getFullYear();
                const fullYear = yearPrefix < 50 ? 2000 + yearPrefix : 1900 + yearPrefix;
                
                if (fullYear < 1950 || fullYear > currentYear) {
                    userIdError.style.display = 'block';
                    userIdError.textContent = '유효하지 않은 입학년도입니다.';
                } else {
                    userIdError.style.display = 'none';
                }
                
                // 학번이 변경되면 이메일 필드도 업데이트
                updateExpectedEmail();
            } else if (userId.length > 0) {
                userIdError.style.display = 'block';
                userIdError.textContent = '학번은 7자리 숫자여야 합니다.';
            } else {
                userIdError.style.display = 'none';
            }
        });
        
        document.getElementById('password').addEventListener('input', function() {
            const passwordError = document.getElementById('passwordError');
            if (this.value.length > 0 && !/^(?=.*[A-Z])(?=.*[!@#$%^&*])(?=.*[0-9])(?=.*[a-z]).{7,14}$/.test(this.value)) {
                passwordError.style.display = 'block';
            } else {
                passwordError.style.display = 'none';
            }
        });
        
        document.getElementById('name').addEventListener('input', function() {
            const nameError = document.getElementById('nameError');
            if (this.value.length > 0 && !/^[가-힣]+$/.test(this.value)) {
                nameError.style.display = 'block';
            } else {
                nameError.style.display = 'none';
            }
        });
        
        document.getElementById('email').addEventListener('input', function() {
            const emailError = document.getElementById('emailError');
            const userId = document.getElementById('userId').value;
            const expectedEmail = userId + '@kunsan.ac.kr';
            
            if (this.value.length > 0 && this.value !== expectedEmail) {
                emailError.style.display = 'block';
            } else {
                emailError.style.display = 'none';
            }
        });
        
        // 학번 입력 시 이메일 필드 자동 업데이트 함수
        function updateExpectedEmail() {
            const userId = document.getElementById('userId').value;
            const emailInput = document.getElementById('email');
            const emailError = document.getElementById('emailError');
            
            if (userId.length === 7 && /^\d{7}$/.test(userId)) {
                const expectedEmail = userId + '@kunsan.ac.kr';
                emailInput.value = expectedEmail;
                emailError.style.display = 'none';
            }
        }
        
        // 페이지 로드 시 이메일 필드 초기화
        window.onload = function() {
            const userId = document.getElementById('userId').value;
            if (userId.length === 7 && /^\d{7}$/.test(userId)) {
                updateExpectedEmail();
            }
        };
    </script>
</body>
</html>
