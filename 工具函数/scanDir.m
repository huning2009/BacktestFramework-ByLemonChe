function [ files ] = scanDir(root_dir,filename_patent)

files={};
if root_dir(end)~='\'
 root_dir=[root_dir,'\'];
end
fileList=dir(root_dir);  %��չ��
n=length(fileList);
cntpic=0;
for i=1:n
    if strcmp(fileList(i).name,'.')==1||strcmp(fileList(i).name,'..')==1
        continue;
    else
        if ~fileList(i).isdir % �������Ŀ¼������
            filename = fileList(i).name;
            if contains(filename,filename_patent)    % ����ļ�������Ҫ���ģʽ�򷵻ؽ��
                full_name=[root_dir,filename];
                cntpic=cntpic+1;
                files(cntpic,:)={full_name};
            end
        else
            files=[files;scanDir([root_dir,fileList(i).name],filename_patent)];
        end
    end
end

end